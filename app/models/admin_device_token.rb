# frozen_string_literal: true

class AdminDeviceToken < ApplicationRecord
  belongs_to :admin_user
  default_scope { order(created_at: :desc) }
  scope :webpush, -> { where(token_type: "webpush", enabled: true) }
end
