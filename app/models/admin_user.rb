class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable, :validatable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable

  validates :email, presence: true
  validates :email, uniqueness: true, if: :will_save_change_to_email?
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i }, if: :will_save_change_to_email?

  validates :password, presence: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  validates :password, length: { in: 8..128 }, if: :password_required?

  validates_inclusion_of   :time_zone, in: ActiveSupport::TimeZone.us_zones.map(&:name)

  private

  def password_required?
    !persisted?
  end
end
