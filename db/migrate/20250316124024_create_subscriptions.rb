class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :endpoint
      t.string :p256dh
      t.string :auth
    end
  end
end
