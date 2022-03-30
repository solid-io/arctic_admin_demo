# frozen_string_literal: true
class CreateSchedules < ActiveRecord::Migration[6.1]
  def change
    create_table :schedules do |t|
      t.integer :scheduleable_id
      t.string :scheduleable_type
      t.string :name
      t.boolean :active, default: false
      t.integer :capacity
      t.string :user_types, array: true
      t.boolean :exclude_lunch_time, default: false
      t.string :lunch_hour_start
      t.string :lunch_hour_end
      t.string :beginning_of_week
      t.string :time_zone

      t.timestamps
    end
    add_index :schedules, [:scheduleable_id, :scheduleable_type]
    add_index :schedules, :active
  end
end
