class CreateScheduleEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :schedule_events do |t|
      t.integer :schedule_id, null: false
      t.datetime :event_time

      t.timestamps
    end
    add_index :schedule_events, :schedule_id
  end
end
