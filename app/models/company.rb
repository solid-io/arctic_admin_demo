class Company < ApplicationRecord
  has_one_attached :logo, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :admin_user_companies
  has_many :admin_users, through: :admin_user_companies
  accepts_nested_attributes_for :locations, allow_destroy: true

  validates :name, :description, :subdomain, :domain, presence: true

  def has_locations?
    self.locations.present?
  end
end
