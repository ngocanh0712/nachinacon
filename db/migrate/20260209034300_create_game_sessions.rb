class CreateGameSessions < ActiveRecord::Migration[7.1]
  def change
    create_table :game_sessions do |t|
      t.string :game_type, null: false
      t.integer :score, default: 0
      t.integer :moves, default: 0
      t.integer :time_seconds, default: 0
      t.string :difficulty
      t.json :metadata
      t.datetime :completed_at

      t.timestamps
    end

    add_index :game_sessions, :game_type
  end
end
