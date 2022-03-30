# frozen_string_literal: true

class AddTimeZoneToAdminUser < ActiveRecord::Migration[6.1]
  def change
    add_column :admin_users, :time_zone, :string
  end
end
