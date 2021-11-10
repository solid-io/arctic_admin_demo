class Company < ApplicationRecord
  has_one_attached :logo, dependent: :destroy
  has_many :locations
  has_many :users, through: :admin_user_companies
  accepts_nested_attributes_for :locations, allow_destroy: true
end
