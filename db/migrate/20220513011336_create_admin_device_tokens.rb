# frozen_string_literal: true

class CreateAdminDeviceTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_device_tokens do |t|
      t.references :admin_user, null: false, foreign_key: true
      t.boolean :enabled
      t.string :token_type
      t.string :token
      t.string :endpoint
      t.string :expiration
      t.string :p256dh
      t.string :os
      t.string :browser
      t.string :user_agent
      t.text :message

      t.timestamps
    end
  end
end
