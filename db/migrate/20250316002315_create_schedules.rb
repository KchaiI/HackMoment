class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.integer :user_id
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
  end
end
