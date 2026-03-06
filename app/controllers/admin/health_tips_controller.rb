# frozen_string_literal: true

module Admin
  class HealthTipsController < BaseController
    before_action :set_health_tip, only: %i[edit update destroy]

    def index
      @health_tips = HealthTip.ordered
    end

    def new
      @health_tip = HealthTip.new
    end

    def create
      @health_tip = HealthTip.new(health_tip_params)

      if @health_tip.save
        flash[:notice] = 'Bài viết sức khoẻ đã được tạo thành công!'
        redirect_to admin_health_tips_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @health_tip.update(health_tip_params)
        flash[:notice] = 'Bài viết sức khoẻ đã được cập nhật!'
        redirect_to admin_health_tips_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @health_tip.destroy
      flash[:notice] = 'Bài viết sức khoẻ đã được xoá.'
      redirect_to admin_health_tips_path
    end

    private

    def set_health_tip
      @health_tip = HealthTip.find(params[:id])
    end

    def health_tip_params
      params.require(:health_tip).permit(:title, :content, :category, :source_url, :image_url, :published, :position)
    end
  end
end
