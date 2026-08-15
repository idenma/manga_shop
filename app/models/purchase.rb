class Purchase < ApplicationRecord
  belongs_to :product

  DOWNLOAD_TOKEN_TTL = 24.hours

  validates :stripe_session_id, presence: true, uniqueness: true
  validates :amount_total, presence: true
  validates :currency, presence: true
  validates :paid_at, presence: true

  def download_token(expires_in: DOWNLOAD_TOKEN_TTL)
    signed_id(purpose: "purchase_download", expires_in: expires_in)
  end
end
