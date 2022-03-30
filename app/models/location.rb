# frozen_string_literal: true
class Location < ApplicationRecord
  belongs_to :company

  def address_display
    ([address_1, address_2, city, state, postal, country].compact.reject { |element| element == "" }).join(", ")
  end
end
