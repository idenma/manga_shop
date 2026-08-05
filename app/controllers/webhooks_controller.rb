class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    payload = request.raw_post
    signature = request.env["HTTP_STRIPE_SIGNATURE"]
    signing_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    event = Stripe::Webhook.construct_event(payload, signature, signing_secret)

    case event.type
    when "checkout.session.completed"
      record_purchase!(event.data.object)
      Rails.logger.info("[StripeWebhook] checkout.session.completed recorded: #{event.id}")
    else
      Rails.logger.info("[StripeWebhook] ignored event: #{event.type}")
    end

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  rescue Stripe::StripeError => e
    Rails.logger.error("[StripeWebhook] stripe error: #{e.message}")
    head :bad_request
  end

  private

  def record_purchase!(checkout_session)
    session_id = checkout_session.id
    return if Purchase.exists?(stripe_session_id: session_id)

    product_id = checkout_session.metadata["product_id"]
    product = Product.find(product_id)

    customer_email = checkout_session.customer_details&.email || checkout_session.customer_email

    Purchase.create!(
      product: product,
      stripe_session_id: session_id,
      customer_email: customer_email,
      amount_total: checkout_session.amount_total,
      currency: checkout_session.currency,
      paid_at: Time.current
    )
  end
end
