# frozen_string_literal: true
class ExampleMailer < ApplicationMailer
  def trust_pilot_invitation(admin_user)
    @admin_user = admin_user || params[:admin_user]
    begin
      # @invitation_link = TrustPilotService.new.service_invitation_link(order)["url"]
      @invitation_link = "https://www.google.com"
      mail(to: @admin_user.email, subject: "Test Now & Go Review Invitation") if @invitation_link
    rescue StandardError => e
      Rails.logger.error("Trust Pilot Invitation Error: #{e.message}")
    end
  end
end
