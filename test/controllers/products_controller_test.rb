require "test_helper"
require "stringio"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { price: @product.price, title: @product.title } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { price: @product.price, title: @product.title } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  test "should forbid download without purchase token" do
    get download_product_url(@product)
    assert_response :forbidden
  end

  test "should allow download with valid purchase token" do
    @product.pdf_file.attach(
      io: StringIO.new("%PDF-1.4 test"),
      filename: "sample.pdf",
      content_type: "application/pdf"
    )

    purchase = Purchase.create!(
      product: @product,
      stripe_session_id: "cs_test_download_1",
      customer_email: "buyer@example.com",
      amount_total: @product.price,
      currency: "jpy",
      paid_at: Time.current
    )

    get download_product_url(@product, purchase_token: purchase.download_token)
    assert_response :redirect
  end
end
