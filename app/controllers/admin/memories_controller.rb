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

      # Process uploaded image and save to public folder
      if params[:memory][:media].present?
        process_and_save_image(@memory, params[:memory][:media])
      end

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
      if params[:remove_image] == '1' && @memory.image_path.present?
        delete_existing_image(@memory)
        @memory.image_path = nil
      end

      # Process uploaded image if present
      if params[:memory][:media].present?
        delete_existing_image(@memory) if @memory.image_path.present?
        process_and_save_image(@memory, params[:memory][:media])
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
      params.require(:memory).permit(:title, :caption, :taken_at, :age_group, :memory_type, :media, :image_path,
                                     album_ids: [], tag_ids: [])
    end

    def delete_existing_image(memory)
      return unless memory.image_path.present?

      file_path = Rails.root.join('public', memory.image_path.delete_prefix('/'))
      File.delete(file_path) if File.exist?(file_path)
      Rails.logger.info "Deleted existing image: #{memory.image_path}"
    rescue StandardError => e
      Rails.logger.error "Error deleting image: #{e.message}"
    end

    def process_and_save_image(memory, uploaded_file)
      require 'mini_magick'

      # Generate unique filename
      timestamp = Time.now.to_i
      random = SecureRandom.hex(8)
      extension = File.extname(uploaded_file.original_filename).downcase
      filename = "memory_#{timestamp}_#{random}#{extension}"

      # Create directory if it doesn't exist
      public_dir = Rails.root.join('public', 'images', 'nachinacon')
      FileUtils.mkdir_p(public_dir)

      # Save original file temporarily
      temp_path = Rails.root.join('tmp', filename)
      File.binwrite(temp_path, uploaded_file.read)

      # Process image with MiniMagick (resize and compress)
      image = MiniMagick::Image.open(temp_path)

      # Resize if larger than 1200px on longest side
      if image.width > 1200 || image.height > 1200
        image.resize '1200x1200>'
      end

      # Compress and optimize
      image.quality '85' # Reduce quality to 85%
      image.strip # Remove EXIF data

      # Save to public folder
      final_path = public_dir.join(filename)
      image.write(final_path)

      # Clean up temp file
      File.delete(temp_path) if File.exist?(temp_path)

      # Set image_path on memory
      memory.image_path = "/images/nachinacon/#{filename}"

      Rails.logger.info "Processed and saved image: #{memory.image_path}"
    rescue StandardError => e
      Rails.logger.error "Error processing image: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
