# frozen_string_literal: true

class ContactTypeLabel < ApplicationRecord
  CONTACT_TYPE_VALUES = {
    "Address" => "address",
    "Email" => "email",
    "Phone" => "phone",
  }

  validates :contact_type, :label, presence: true

  scope :address_labels, -> { where(contact_type: "address") }
  scope :phone_labels, -> { where(contact_type: "phone") }

  before_save :humanize_label, if: :label_changed

  private
    def humanize_label
      self.label = self.label.humanize
    end

    def label_changed
      self.label_changed?
    end
end
