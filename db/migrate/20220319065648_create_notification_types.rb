# frozen_string_literal: true

class CreateNotificationTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :notification_types do |t|
      t.string :name
      t.boolean :email_enabled, default: true
      t.string :mailer
      t.string :email
      t.boolean :push_enabled, default: true
      t.string :push_summary
      t.text :push_details
      t.boolean :sms_enabled, default: false
      t.text :sms_body

      t.timestamps
    end
  end
end
