class AddImagePathToMemories < ActiveRecord::Migration[7.1]
  def change
    add_column :memories, :image_path, :string
  end
end
