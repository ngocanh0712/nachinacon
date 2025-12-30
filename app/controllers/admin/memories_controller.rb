# frozen_string_literal: true

module Admin
  class MemoriesController < BaseController
    before_action :set_memory, only: %i[show edit update destroy]

    def index
      @memories = Memory.includes(:tags).recent

      # Search by title or caption
      if params[:q].present?
        @memories = @memories.where("title LIKE ? OR caption LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%")
      end

      # Filter by age group
      if params[:age_group].present?
        @memories = @memories.where(age_group: params[:age_group])
      end

      # Filter by memory type
      if params[:memory_type].present?
        @memories = @memories.where(memory_type: params[:memory_type])
      end

      # Pagination
      @pagy, @memories = pagy(@memories, items: 12)
    end

    def show; end

    def new
      @memory = Memory.new
    end

    def create
      @memory = Memory.new(memory_params)

      if @memory.save
        flash[:notice] = 'Kỷ niệm đã được tạo thành công!'
        redirect_to admin_memories_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      # Handle image deletion
      if params[:remove_image] == '1' && @memory.media.attached?
        @memory.media.purge
      end

      if @memory.update(memory_params)
        flash[:notice] = 'Kỷ niệm đã được cập nhật!'
        redirect_to admin_memories_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @memory.destroy
      flash[:notice] = 'Kỷ niệm đã được xóa.'
      redirect_to admin_memories_path
    end

    private

    def set_memory
      @memory = Memory.find(params[:id])
    end

    def memory_params
      params.require(:memory).permit(:title, :caption, :taken_at, :age_group, :memory_type, :media,
                                     album_ids: [], tag_ids: [])
    end
  end
end
