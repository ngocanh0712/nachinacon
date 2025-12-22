class CreateAlbumMemories < ActiveRecord::Migration[7.1]
  def change
    create_table :album_memories do |t|
      t.references :album, null: false, foreign_key: true
      t.references :memory, null: false, foreign_key: true

      t.timestamps
    end
  end
end
