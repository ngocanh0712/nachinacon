class CreateGrowthRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :growth_records do |t|
      t.date :recorded_on, null: false
      t.decimal :height_cm, precision: 5, scale: 1
      t.decimal :weight_kg, precision: 5, scale: 2
      t.decimal :head_cm, precision: 5, scale: 1
      t.text :notes

      t.timestamps
    end
    add_index :growth_records, :recorded_on, unique: true
  end
end
