class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|      
      t.string :name
      t.string :location
      t.text :status
      t.integer :current_activity_id
      t.integer :profile_picture_id
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :access_token
      t.datetime :access_token_created_at
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
