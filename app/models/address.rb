class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  validates :label, :address_line_1, :city, :state, :zip, presence: true
end
