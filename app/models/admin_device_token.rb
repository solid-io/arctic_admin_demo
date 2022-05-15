# frozen_string_literal: true

class AdminDeviceToken < ApplicationRecord
  # https://www.youtube.com/watch?v=d0XJ9cLfoTs&t=496s
  # https://www.youtube.com/watch?v=T6vdjAvGr1Q
  belongs_to :admin_user

  default_scope { order(created_at: :desc) }
  scope :webpush, -> { where(token_type: "webpush", enabled: true) }

  def publish
    message = {
      title: "We are in the Title",
      body: "The body is where it's at!",
      icon: "/android-chrome-192x192.png",
    }

    begin
      response = Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: endpoint,
        auth: token,
        p256dh: p256dh,
        ttl: 24 * 60 * 60,
        vapid: {
          subject: "mailto:arctic_admin_demo@example.com",
          public_key: Rails.application.credentials.webpush[:public_key],
          private_key: Rails.application.credentials.webpush[:private_key],
        },
        data: {
        dateOfArrival: Time.now,
        primaryKey: 1
        },
        actions: [
          { action: "explore", title: "Explore this new world",
            icon: "images/checkmark.png" },
          { action: "close", title: "I don't want any of this",
            icon: "images/xmark.png" },
        ]
      )

      self.update!(message: response.class)

    rescue Webpush::ExpiredSubscription => e
      Rails.logger.error "Webpush send error: #{e.message}"
      self.update!(enabled: false, message: e.message)
      Rails.logger.error "Disable Device Token - Status: #{self.enabled}"
    end
  end
end
