class CreateMemories < ActiveRecord::Migration[7.1]
  def change
    create_table :memories do |t|
      t.string :title
      t.text :caption
      t.datetime :taken_at
      t.string :age_group
      t.string :memory_type

      t.timestamps
    end
    add_index :memories, :memory_type
  end
end
