# frozen_string_literal: true

class DeliveryMethods::Webpush < Noticed::DeliveryMethods::Base
  # https://www.youtube.com/watch?v=d0XJ9cLfoTs&t=496s
  # https://www.youtube.com/watch?v=T6vdjAvGr1Q
  def deliver
    message = {
      title: "We are in the Title",
      body: "The body is where it's at!",
      icon: "/android-chrome-192x192.png",
    }

    recipient.admin_device_tokens.webpush.each do |device_token|
      response = Webpush.payload_send(
        message: JSON.generate(message),
        endpoint: device_token.endpoint,
        auth: device_token.token,
        p256dh: device_token.p256dh,
        ttl: 24 * 60 * 60,
        vapid: {
          subject: "mailto:sender@example.com",
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

      device_token.update!(message: response.class)

    rescue StandardError => e
      Rails.logger.error "Webpush send error: #{e.message}"
      device_token.update!(enabled: false, message: e.message)
      Rails.logger.error "Disable Device Token - Status: #{device_token.enabled}"
    end
  end

  # You may override this method to validate options for the delivery method
  # Invalid options should raise a ValidationError
  #
  # def self.validate!(options)
  #   raise ValidationError, "required_option missing" unless options[:required_option]
  # end
end
