require "test_helper"
require "ostruct"

class WebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "returns ok when stripe webhook event is valid" do
    payload = {
      id: "evt_test_123",
      type: "checkout.session.completed",
      data: { object: { id: "cs_test_123" } }
    }.to_json

    checkout_session = OpenStruct.new(
      id: "cs_test_123",
      metadata: { "product_id" => @product.id.to_s },
      amount_total: @product.price,
      currency: "jpy",
      customer_details: OpenStruct.new(email: "buyer@example.com"),
      customer_email: nil
    )

    fake_event = OpenStruct.new(
      id: "evt_test_123",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: checkout_session)
    )

    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.singleton_class.send(:define_method, :construct_event) do |_payload, _signature, _secret|
      fake_event
    end

    begin
      assert_difference("Purchase.count", 1) do
        post stripe_webhook_url,
             params: payload,
             headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "dummy" }
      end
    ensure
      Stripe::Webhook.singleton_class.send(:define_method, :construct_event, original)
    end

    assert_response :ok
  end

  test "keeps one purchase when same checkout session is received twice" do
    payload = {
      id: "evt_test_dupe",
      type: "checkout.session.completed",
      data: { object: { id: "cs_test_dupe" } }
    }.to_json

    checkout_session = OpenStruct.new(
      id: "cs_test_dupe",
      metadata: { "product_id" => @product.id.to_s },
      amount_total: @product.price,
      currency: "jpy",
      customer_details: OpenStruct.new(email: "dupe@example.com"),
      customer_email: nil
    )

    fake_event = OpenStruct.new(
      id: "evt_test_dupe",
      type: "checkout.session.completed",
      data: OpenStruct.new(object: checkout_session)
    )

    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.singleton_class.send(:define_method, :construct_event) do |_payload, _signature, _secret|
      fake_event
    end

    begin
      post stripe_webhook_url,
           params: payload,
           headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "dummy" }

      assert_no_difference("Purchase.count") do
        post stripe_webhook_url,
             params: payload,
             headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "dummy" }
      end
    ensure
      Stripe::Webhook.singleton_class.send(:define_method, :construct_event, original)
    end

    assert_response :ok
  end

  test "returns bad_request when signature verification fails" do
    payload = { id: "evt_bad" }.to_json

    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.singleton_class.send(:define_method, :construct_event) do |_payload, _signature, _secret|
      raise JSON::ParserError, "invalid JSON"
    end

    begin
      post stripe_webhook_url,
           params: payload,
           headers: { "CONTENT_TYPE" => "application/json", "HTTP_STRIPE_SIGNATURE" => "dummy" }
    ensure
      Stripe::Webhook.singleton_class.send(:define_method, :construct_event, original)
    end

    assert_response :bad_request
  end
end
