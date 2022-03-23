class AdminUserHelpPreference < ApplicationRecord
  belongs_to :admin_user
  validates :controller_name, presence: true
end
