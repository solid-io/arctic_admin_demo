password = Rails.application.credentials[:demo_password]
AdminUser.create!(email: 'admin@example.com', password: password, password_confirmation: password) if Rails.env.development?