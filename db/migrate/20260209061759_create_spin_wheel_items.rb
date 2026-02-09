class CreateSpinWheelItems < ActiveRecord::Migration[7.1]
  def change
    create_table :spin_wheel_items do |t|
      t.string :label, null: false
      t.string :emoji, null: false
      t.string :category, null: false, default: 'challenge'
      t.string :color, null: false, default: '#C1DDD8'
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :spin_wheel_items, :active
    add_index :spin_wheel_items, :position
  end
end
