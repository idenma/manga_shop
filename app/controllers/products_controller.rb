# app/controllers/products_controller.rb
class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy download ]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = Product.new
  end

  def edit
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: "商品を登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: "商品を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: "商品を削除しました。"
  end

  def download
    token = params[:purchase_token]
    purchase = Purchase.find_signed(token, purpose: "purchase_download") if token.present?

    return head :forbidden unless purchase&.product_id == @product.id
    return head :not_found unless @product.pdf_file.attached?

    redirect_to rails_blob_path(@product.pdf_file, disposition: :attachment)
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    # :pdf_file を許可リストに追加
    params.require(:product).permit(:title, :price, :description, :pdf_file)
  end
end
