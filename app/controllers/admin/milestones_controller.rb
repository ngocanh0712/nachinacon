# frozen_string_literal: true

module Admin
  class MilestonesController < BaseController
    before_action :set_milestone, only: %i[show edit update destroy]

    def index
      @achieved = Milestone.achieved
      @pending = Milestone.pending
    end

    def show; end

    def new
      @milestone = Milestone.new
    end

    def create
      @milestone = Milestone.new(milestone_params)

      if @milestone.save
        flash[:notice] = 'Milestone đã được tạo thành công!'
        redirect_to admin_milestones_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @milestone.update(milestone_params)
        flash[:notice] = 'Milestone đã được cập nhật!'
        redirect_to admin_milestones_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @milestone.destroy
      flash[:notice] = 'Milestone đã được xóa.'
      redirect_to admin_milestones_path
    end

    private

    def set_milestone
      @milestone = Milestone.find(params[:id])
    end

    def milestone_params
      params.require(:milestone).permit(:name, :description, :achieved_at, :milestone_type, :icon, :photo)
    end
  end
end
