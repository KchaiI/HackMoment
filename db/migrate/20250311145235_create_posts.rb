class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :img
      t.string :text
      t.timestamps
      t.integer :user_id
    end
  end
end
