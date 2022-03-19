# Preview all emails at http://localhost:3000/rails/mailers/example_mailer
class ExampleMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/example_mailer/trust_pilot_invitation
  def trust_pilot_invitation
    @admin_user = AdminUser.last
    @invitation_link = "https://www.google.com"
    ExampleMailer.trust_pilot_invitation(@admin_user)
  end

end
