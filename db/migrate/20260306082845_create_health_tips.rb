class CreateHealthTips < ActiveRecord::Migration[7.1]
  def change
    create_table :health_tips do |t|
      t.string :title
      t.text :content
      t.string :category
      t.string :source_url
      t.string :image_url
      t.boolean :published, default: true
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
