# frozen_string_literal: true
# Preview all emails at http://localhost:3000/rails/mailers/schedule_mailer
class ScheduleMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/schedule_mailer/create
  def create
    ScheduleMailer.create
  end

  # Preview this email at http://localhost:3000/rails/mailers/schedule_mailer/update
  def update
    ScheduleMailer.update
  end
end
