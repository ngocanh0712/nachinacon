# frozen_string_literal: true

module Admin
  class MemoriesController < BaseController
    before_action :set_memory, only: %i[show edit update destroy]

    def index
      @memories = Memory.recent
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
      params.require(:memory).permit(:title, :caption, :taken_at, :age_group, :memory_type, :media, album_ids: [])
    end
  end
end
