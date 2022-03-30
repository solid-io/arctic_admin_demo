# frozen_string_literal: true

class AdminUserHelpPreference < ApplicationRecord
  belongs_to :admin_user
  validates :controller_name, presence: true
end
