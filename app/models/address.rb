# frozen_string_literal: true
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  validates :label, :address_line_1, :city, :state, :zip, presence: true

  # def display
  #   ([label, address_line_1, address_line_2, city, state, zip, country].compact.reject {|element| element == "" }).join(', ')
  # end
end
