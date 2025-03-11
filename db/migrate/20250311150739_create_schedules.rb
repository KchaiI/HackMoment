class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.date :start_time
      t.date :end_time
      t.timestamps
    end
  end
end
