 # frozen_string_literal: true

 p "Seeding database..."

 if Rails.env.development?
   demo_email = Rails.application.credentials.seed[:demo_email]
   demo_password = Rails.application.credentials.seed[:demo_password]
   admin_email = Rails.application.credentials.seed[:admin_email]

   company_epi = Company.create!(name: "Empowering Partnerships Inc.", description: "EPI...", subdomain: "epi", domain: "epi.dev")
   company_hgs = Company.create!(name: "Higher Ground Solutions", description: "HGS...", subdomain: "hgs", domain: "hgs.dev")

   company_epi.locations.create!(name: "Main Office", address_1: "311 Main Vista Drive", address_2: "", city: "Dallas", state: "Texas", postal: "75420", country: "US", time_zone: "Central Time (US & Canada)")
   company_epi.locations.create!(name: "Satellite Office", address_1: "10000 Julian Way", address_2: "", city: "Westminster", state: "Colorado", postal: "80031", country: "US", time_zone: "Mountain Time (US & Canada)")

   super_admin = AdminUser.create!(first_name: "Jack", last_name: "Paradise", email: demo_email, password: demo_password, password_confirmation: demo_password, time_zone: "Pacific Time (US & Canada)")
   super_admin.admin_user_companies.create!(company_id: company_epi.id)
   AdminUserNotificationPreference.create!(admin_user_id: super_admin.id) # DB Defaults = email_enabled: true, push_enabled: true, sns_enabled: false
   super_admin.admin_user_help_preferences.create!(admin_user_id: super_admin.id, controller_name: "notification_types") # DB Defaults = enabled: true
   super_admin.admin_user_help_preferences.create!(admin_user_id: super_admin.id, controller_name: "schedules") # DB Defaults = enabled: true
   super_admin.addresses.create!(label: "Home", address_line_1: "123 Example Lane", address_line_2: "", city: "Dallas", state: "TX", zip: "75227", default: true)
   super_admin.addresses.create!(label: "Home", address_line_1: "311 Home Brew Road", address_line_2: "", city: "Omaha", state: "NE", zip: "68104", default: false)


   admin = AdminUser.create!(first_name: "Jason", last_name: "Rossi", email: admin_email, password: demo_password, password_confirmation: demo_password, time_zone: "Pacific Time (US & Canada)")
   admin.admin_user_companies.create!(company_id: company_hgs.id)
   AdminUserNotificationPreference.create!(admin_user_id: admin.id) # DB Defaults = email_enabled: true, push_enabled: true, sns_enabled: false
   admin.admin_user_help_preferences.create!(admin_user_id: admin.id, controller_name: "notification_types") # DB Defaults = enabled: true

   schedule = Schedule.create!(name: "Appointments", time_zone: "Mountain Time (US & Canada)",  beginning_of_week: "sunday", exclude_lunch_time: false, lunch_hour_start: "", lunch_hour_end: "")
   schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule MWF", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["monday", "wednesday", "friday"], start_date: Date.today, end_date: Date.today + 90.days, rule_hour_start: "08:00", rule_hour_end: "20:00")
   schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule TTH", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["tuesday", "thursday"], start_date: Date.today + 1.week, end_date: Date.today + 90.days, rule_hour_start: "17:15", rule_hour_end: "23:45")

   NotificationType.create!(name: "ScheduleMailer.update", email_enabled: true, mailer: "ScheduleMailer", email: "update", push_enabled: true, push_summary: "The schedule has been updated.", push_details: "Updated Schedule", sms_enabled: false, sms_body: "")
   NotificationType.create!(name: "ExampleMailer.trust_pilot_invitation", email_enabled: true, mailer: "ExampleMailer", email: "trust_pilot_invitation", push_enabled: false, push_summary: "", push_details: "", sms_enabled: false, sms_body: "")

   ContactTypeLabel.create!(contact_type: "email", label: "Office")
   ContactTypeLabel.create!(contact_type: "email", label: "Home")
   ContactTypeLabel.create!(contact_type: "phone", label: "Shipping")
   ContactTypeLabel.create!(contact_type: "phone", label: "Office")
   ContactTypeLabel.create!(contact_type: "phone", label: "Mobile")
   ContactTypeLabel.create!(contact_type: "phone", label: "Home")
   ContactTypeLabel.create!(contact_type: "phone", label: "Billing")
   ContactTypeLabel.create!(contact_type: "address", label: "Shipping")
   ContactTypeLabel.create!(contact_type: "address", label: "Office")
   ContactTypeLabel.create!(contact_type: "address", label: "Home")
   ContactTypeLabel.create!(contact_type: "address", label: "Billing")

   5.times do
     Company.create!(name: Faker::Company.name, description: Faker::Company.bs, subdomain: Faker::Internet.domain_name(subdomain: true, domain: "example"), domain: Faker::Internet.domain_name(domain: "example"))
   end

 end
