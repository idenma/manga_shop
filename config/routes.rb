# config/routes.rb
Rails.application.routes.draw do
  # トップページを商品一覧画面（products#index）にする
  root "products#index"

  resources :products
end