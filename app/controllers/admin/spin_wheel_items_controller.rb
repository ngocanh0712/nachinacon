# frozen_string_literal: true

module Admin
  class SpinWheelItemsController < BaseController
    before_action :set_item, only: %i[edit update destroy]

    def index
      @items = SpinWheelItem.ordered
    end

    def new
      @item = SpinWheelItem.new
    end

    def create
      @item = SpinWheelItem.new(item_params)
      @item.position = SpinWheelItem.maximum(:position).to_i + 1

      if @item.save
        flash[:notice] = 'Item đã được tạo!'
        redirect_to admin_spin_wheel_items_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @item.update(item_params)
        flash[:notice] = 'Item đã được cập nhật!'
        redirect_to admin_spin_wheel_items_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @item.destroy
      flash[:notice] = 'Item đã được xóa.'
      redirect_to admin_spin_wheel_items_path
    end

    private

    def set_item
      @item = SpinWheelItem.find(params[:id])
    end

    def item_params
      params.require(:spin_wheel_item).permit(:label, :emoji, :category, :color, :active, :position)
    end
  end
end
