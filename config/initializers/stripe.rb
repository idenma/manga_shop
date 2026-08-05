# Stripe の秘密鍵を環境変数から読み込む
if ENV["STRIPE_SECRET_KEY"].present?
  Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
end
