# frozen_string_literal: true

class CreateAdminUserNotificationPreferences < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_user_notification_preferences do |t|
      t.belongs_to :admin_user, null: false, foreign_key: true
      t.boolean :email_enabled, default: true
      t.boolean :push_enabled, default: true
      t.boolean :sms_enabled, default: false

      t.timestamps
    end
  end
end
