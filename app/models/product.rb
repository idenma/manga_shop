# app/models/product.rb
class Product < ApplicationRecord
  # PDFファイルを1つアタッチできるようにする
  has_one_attached :pdf_file

  validates :title, presence: true
  validates :price, presence: true
end