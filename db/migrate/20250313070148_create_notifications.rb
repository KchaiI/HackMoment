class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notification do |t|
      t.integer :user_id
      t.timestamps
    end
  end
end
