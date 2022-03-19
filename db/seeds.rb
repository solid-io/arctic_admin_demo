 if Rails.env.development?
  password = Rails.application.credentials[:demo_password]

  company_epi = Company.create!( name: "Empowering Partnerships Inc.", description: "EPI...", subdomain: "epi", domain: "epi.dev")
  company_hgs = Company.create!( name: "Higher Ground Solutions", description: "HGS...", subdomain: "hgs", domain: "hgs.dev")

  company_epi.locations.create!(name: "Main Office", address_1: "311 Main Vista Drive", address_2: "", city: "Dallas", state: "Texas", postal: "75420", country: "US", time_zone: "Central Time (US & Canada)")
  company_epi.locations.create!(name: "Satellite Office", address_1: "10000 Julian Way", address_2: "", city: "Westminster", state: "Colorado", postal: "80031", country: "US", time_zone: "Mountain Time (US & Canada)")

  super_admin = AdminUser.create!(email: 'admin@example.com', password: password, password_confirmation: password, time_zone: 'Pacific Time (US & Canada)')
  super_admin.admin_user_companies.create!(company_id: company_epi.id)

  admin = AdminUser.create!(email: Rails.application.credentials[:admin_email], password: password, password_confirmation: password, time_zone: 'Pacific Time (US & Canada)')
  admin.admin_user_companies.create!(company_id: company_epi.id)

  schedule = Schedule.create!(name: "Appointments", time_zone: "Mountain Time (US & Canada)",  beginning_of_week: "sunday", exclude_lunch_time: false, lunch_hour_start: "", lunch_hour_end: "")
  schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule MWF", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["monday","wednesday","friday"], start_date: Date.today, end_date: Date.today + 90.days, rule_hour_start: "08:00", rule_hour_end: "20:00")
  schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule TTH", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["tuesday","thursday"], start_date: Date.today + 1.week, end_date: Date.today + 90.days, rule_hour_start: "17:15", rule_hour_end: "23:45")

  NotificationType.create!(name: "ScheduleMailer.update", email_enabled: true, mailer: "ScheduleMailer", email: "update", push_enabled: true, push_summary: "The schedule has been updated.", push_details: "Updated Schedule", sms_enabled: false, sms_body: "")
  NotificationType.create!(name: "ExampleMailer.trust_pilot_invitation", email_enabled: true, mailer: "ExampleMailer", email: "trust_pilot_invitation", push_enabled: false, push_summary: "", push_details: "", sms_enabled: false, sms_body: "")
end
