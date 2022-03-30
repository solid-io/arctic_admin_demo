# frozen_string_literal: true
class AdminUserNotificationPreference < ApplicationRecord
  belongs_to :admin_user
end
