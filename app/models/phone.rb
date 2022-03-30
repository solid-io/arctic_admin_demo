# frozen_string_literal: true

class Phone < ApplicationRecord
  belongs_to :phoneable, polymorphic: true

  before_save :process_phone_number

  def process_phone_number
    self.is_valid = Utils::Phone.validate(phone_number)["valid"]
    self.phone_number = Utils::Phone.normalize(phone_number)
  end
end
