class Purchase < ApplicationRecord
  belongs_to :product

  validates :stripe_session_id, presence: true, uniqueness: true
  validates :amount_total, presence: true
  validates :currency, presence: true
  validates :paid_at, presence: true
end
