# frozen_string_literal: true

class AdminUser < ApplicationRecord
  has_person_name
  has_one_attached :avatar, dependent: :destroy
  has_many :admin_user_companies, dependent: :destroy
  has_many :companies, through: :admin_user_companies
  has_many :locations, through: :companies
  has_many :admin_user_help_preferences, dependent: :destroy
  has_one :admin_user_notification_preference, dependent: :destroy
  has_many :addresses, as: :addressable
  has_many :phones, as: :phoneable
  has_many :admin_device_tokens, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy

  accepts_nested_attributes_for :admin_user_companies, allow_destroy: true
  accepts_nested_attributes_for :admin_user_help_preferences, allow_destroy: true
  accepts_nested_attributes_for :admin_user_notification_preference
  accepts_nested_attributes_for :addresses, allow_destroy: true
  accepts_nested_attributes_for :phones, allow_destroy: true

  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable, :omniauthable, :validatable
  devise :database_authenticatable, :lockable,
         :recoverable, :rememberable, :trackable

  validates :email, presence: true
  validates :email, uniqueness: true, if: :will_save_change_to_email?
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i }, if: :will_save_change_to_email?

  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  validates :password, length: { in: 8..128 }, if: :password_required?

  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.us_zones.map(&:name)

  after_commit :send_update_notifications, if: :allow
  after_create :add_admin_user_notification_preferences

  def send_update_notifications
    # ExampleMailer.trust_pilot_invitation(self).deliver_now
  end

  def allow
    self.time_zone != "Pacific Time (US & Canada)"
  end

  def lock
    self.update!(locked_at: Time.now)
  end

  def unlock
    self.update!(locked_at: nil, failed_attempts: 0)
  end

  private
    def add_admin_user_notification_preferences
      AdminUserNotificationPreference.create!(admin_user_id: self.id) # DB Defaults = email_enabled: true, push_enabled: true, sns_enabled: false
    end

    def password_required?
      !persisted?
    end
end
