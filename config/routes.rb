# config/routes.rb
Rails.application.routes.draw do
  # トップページを商品一覧画面（products#index）にする
  root "products#index"

  resources :products do
    post :checkout, to: "checkouts#create", on: :member
  end

  get "checkout/success", to: "checkouts#success", as: :checkout_success
  get "checkout/cancel", to: "checkouts#cancel", as: :checkout_cancel
  post "stripe/webhook", to: "webhooks#stripe", as: :stripe_webhook
end
