class NotificationType < ApplicationRecord
  MAILERS = Dir["app/mailers/**/*.rb"].freeze
  CLASSIFIED_MAILERS = MAILERS.map { |mailer| mailer.gsub("app/mailers/", "").gsub(".rb", "").classify }.reject { |r| r == "ApplicationMailer" }.sort.freeze

  validates :name, uniqueness: true, presence: true
  validates :mailer, :email, presence: true, if: :email_enabled
  validates :push_summary, :push_details, presence: true, if: :push_enabled
  validates :sms_body, presence: true, if: :sms_enabled
  validate :email_must_belong_to_processed_mailers

  def emails
    emails = []
    CLASSIFIED_MAILERS.each do |mailer|
      sorted_email_methods = mailer.constantize.instance_methods(false).map { |method| method.to_s }.reject(&:empty?).sort
      sorted_email_methods.each do |email|
        emails << ["#{mailer} - #{email}", email]
      end
    end
    emails
  end

  def preview
    previews = []
    ActionMailer::Preview.all().each do |preview|
      emails = preview.emails().sort
      emails.each do |email|
        previews << ["#{preview} - #{email}", email]
      end
    end
    previews
    previews.find { |el| el[0].start_with?("#{mailer}Preview") && el[1] == email }
  end

  def mailer_email_present
    mailer.present? && email.present?
  end

  def mailer_emails_by_email
    match_mailer_by_email[0]
  end

  def match_mailer_by_email
    emails.find { |el| el[0].start_with?(mailer) && el[1] == email }
  end

  def email_must_belong_to_processed_mailers
    if mailer.present? && !match_mailer_by_email
      errors.add(:email, "must match mailer '#{mailer}'")
    end
  end
end
