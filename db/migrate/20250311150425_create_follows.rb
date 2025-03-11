class CreateFollows < ActiveRecord::Migration[6.1]
  def change
    create_table :follows do |t|
      t.integer :followed_id
      t.integer :following_id
      t.timestamps
    end
  end
end
