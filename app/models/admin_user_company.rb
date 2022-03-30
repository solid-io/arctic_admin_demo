# frozen_string_literal: true
class AdminUserCompany < ApplicationRecord
  belongs_to :admin_user
  belongs_to :company
end
