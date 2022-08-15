class Api::V1::CartListsController < ApplicationController
  before_action :authenticate_user!

  def index
    user_cart = current_user.carts.includes([:cart_lists])
    category_items_count = { category: {}, items: {} }
    user_cart.each do |cart|
      group_items = cart.cart_lists.group(:product_name).count
      group_category = cart.cart_lists.group(:product_category).count
      category_items_count[:items] = group_items
      category_items_count[:category] = group_category
    end
    render json: {
      data: category_items_count,
      status: 200
    }
  end

  def create
    cart = current_user.carts.find_by(active: true)
    new_cart_list = cart.cart_lists.create(new_list_params)

    save_item(new_cart_list)
  end

  def save_item(new_item)
    if new_item.save
      render json: {
        message: 'Cart Item created succesfully',
        status: 201
      }
    else
      render json: {
        message: 'Cart Item created unsuccesfully',
        status: 400
      }
    end
  end

  # def group_keys(object, item)
  #   object.collect do |key, value|
  #     if item.key?(key.name)
  #       item[key.name] += value
  #     else
  #       item[key.name] = value
  #     end
  #   end
  # end

  private

  def new_list_params
    params.require(:new_cart_list).permit(:product_name, :product_category, :quantity, :measurement_unit)
  end
end
