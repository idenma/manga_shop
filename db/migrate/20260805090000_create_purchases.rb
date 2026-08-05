class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases do |t|
      t.references :product, null: false, foreign_key: true
      t.string :stripe_session_id, null: false
      t.string :customer_email
      t.integer :amount_total, null: false
      t.string :currency, null: false
      t.datetime :paid_at, null: false

      t.timestamps
    end

    add_index :purchases, :stripe_session_id, unique: true
  end
end
