class Company < ApplicationRecord
  has_one_attached :logo, dependent: :destroy
  has_many :locations
  accepts_nested_attributes_for :locations, allow_destroy: true
end
