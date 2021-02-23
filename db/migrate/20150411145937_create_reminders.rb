class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.text :content, null: false
      t.integer :time_margin
      t.references :activity, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
