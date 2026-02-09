class CreateReactions < ActiveRecord::Migration[7.1]
  def change
    create_table :reactions do |t|
      t.references :memory, null: false, foreign_key: true
      t.string :emoji, null: false
      t.integer :count, default: 0

      t.timestamps
    end

    add_index :reactions, [:memory_id, :emoji], unique: true
  end
end
