class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :name, null: false

      # Start time
      t.integer :start_time_hour
      t.integer :start_time_min

      # End time
      t.integer :end_time_hour
      t.integer :end_time_min

      # Date in ISO 8601 format YYYY-MM-DD without time
      t.string :start_date
      t.string :end_date

      t.boolean :is_repeating, null: false, default: false
      t.boolean :confirm_when_finished, null: false, default: false
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
