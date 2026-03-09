class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :content
      t.string :category
      t.string :image_url
      t.string :source_url
      t.boolean :published, default: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
