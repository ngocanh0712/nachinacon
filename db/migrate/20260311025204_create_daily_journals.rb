class CreateDailyJournals < ActiveRecord::Migration[7.1]
  def change
    create_table :daily_journals do |t|
      t.date :date, null: false
      t.integer :mood, default: 0, null: false
      t.decimal :sleep_hours, precision: 3, scale: 1
      t.text :eat_note
      t.text :activity_note
      t.text :note

      t.timestamps
    end

    add_index :daily_journals, :date, unique: true
    add_index :daily_journals, :mood
  end
end
