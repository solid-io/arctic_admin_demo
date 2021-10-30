class CreateRules < ActiveRecord::Migration[6.1]
  def change
    create_table :rules do |t|
      t.integer :schedule_id, null: false
      t.string :rule_type
      t.string :name
      t.string :frequency_units
      t.string :frequency
      t.string :days_of_week, array: true
      t.date :start_date
      t.date :end_date
      t.string :rule_hour_start
      t.string :rule_hour_end

      t.timestamps
    end
    add_index :rules, :schedule_id
  end
end
