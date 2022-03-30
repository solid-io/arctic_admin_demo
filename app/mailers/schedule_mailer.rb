# frozen_string_literal: true

class ScheduleMailer < ApplicationMailer
  # before_action { @schedule, @user = params[:schedule], params[:current_user] }

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.schedule_mailer.create.subject
  #
  def create
    @greeting = "Hi"

    mail to: "jasonc.rossi@gmail.com"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.schedule_mailer.update.subject
  #
  def update
    @greeting = "Hi"

    mail to: "jasonc.rossi@gmail.com"
  end
end
