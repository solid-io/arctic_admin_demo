password = Rails.application.credentials[:demo_password]
AdminUser.create!(email: 'admin@example.com', password: password, password_confirmation: password, time_zone: 'Pacific Time (US & Canada)') if Rails.env.development?

schedule = Schedule.create!(name: "Appointments", time_zone: "Mountain Time (US & Canada)",  beginning_of_week: "sunday", exclude_lunch_time: false, lunch_hour_start: "", lunch_hour_end: "")

schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule MWF", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["monday","wednesday","friday"], start_date: Date.today, end_date: Date.today + 90.days, rule_hour_start: "08:00", rule_hour_end: "20:00")
schedule.rules.create!(rule_type: "inclusion", name: "Open Time Rule TTH", frequency_units: "IceCube::MinutelyRule", frequency: 15, days_of_week: ["tuesday","thursday"], start_date: Date.today + 1.week, end_date: Date.today + 90.days, rule_hour_start: "17:15", rule_hour_end: "23:45")

