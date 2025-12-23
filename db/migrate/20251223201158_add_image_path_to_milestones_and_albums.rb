class AddImagePathToMilestonesAndAlbums < ActiveRecord::Migration[7.1]
  def change
    add_column :milestones, :image_path, :string
    add_column :albums, :cover_image_path, :string
  end
end
