# frozen_string_literal: true

module Admin
  class AlbumsController < BaseController
    before_action :set_album, only: [:edit, :update, :destroy]

    def index
      @albums = Album.with_memories.recent
    end

    def new
      @album = Album.new
    end

    def create
      @album = Album.new(album_params)
      if @album.save
        redirect_to admin_albums_path, notice: 'Album đã được tạo thành công.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @album.update(album_params)
        redirect_to admin_albums_path, notice: 'Album đã được cập nhật.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @album.destroy
      redirect_to admin_albums_path, notice: 'Album đã được xóa.'
    end

    private

    def set_album
      @album = Album.find(params[:id])
    end

    def album_params
      params.require(:album).permit(:name, :description, :cover_photo)
    end
  end
end
