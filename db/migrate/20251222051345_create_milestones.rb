class CreateMilestones < ActiveRecord::Migration[7.1]
  def change
    create_table :milestones do |t|
      t.string :name
      t.text :description
      t.date :achieved_at
      t.string :milestone_type
      t.string :icon

      t.timestamps
    end
  end
end
