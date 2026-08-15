class CheckoutsController < ApplicationController
  def create
    product = Product.find(params[:id])

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: "jpy",
            unit_amount: product.price,
            product_data: {
              name: product.title
            }
          }
        }
      ],
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url(product_id: product.id),
      metadata: {
        product_id: product.id
      }
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue Stripe::StripeError => e
    redirect_to product_url(product), alert: "決済ページの作成に失敗しました: #{e.message}"
  end

  def success
    @purchase = Purchase.find_by(stripe_session_id: params[:session_id])
    return if @purchase.blank?

    @product = @purchase.product
    @download_token = @purchase.download_token
  end

  def cancel
    @product = Product.find_by(id: params[:product_id])
  end
end
