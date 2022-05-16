# frozen_string_literal: true

# https://app.abstractapi.com/users/login

class AbstractService
  def self.ip_geolocation
    connection ||= Faraday.new do |connect|
      connect.url_prefix = URI("https://ipgeolocation.abstractapi.com/v1/?api_key=#{credentials[:ip_key]}")
      connect.response :json, content_type: "application/json"
    end

    response = connection.get()
    response.body.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error "Abstract IP Geolocation Service Error Message: #{e.message}"
  end

  def self.email_validation(email)
    connection ||= Faraday.new do |connect|
      connect.url_prefix = URI("https://emailvalidation.abstractapi.com/v1/?api_key=#{credentials[:email_key]}&email=#{email}")
      connect.response :json, content_type: "application/json"
    end

    response = connection.get()
    response.body.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error "Abstract Email Validation Service Error Message: #{e.message}"
  end

  def self.phone_validation(phone)
    connection ||= Faraday.new do |connect|
      connect.url_prefix = URI("https://phonevalidation.abstractapi.com/v1/?api_key=#{credentials[:phone_key]}&phone=#{phone}")
      connect.response :json, content_type: "application/json"
    end

    response = connection.get()
    response.body.with_indifferent_access
    rescue StandardError => e
      Rails.logger.error "Abstract Phone Validation Service Error Message: #{e.message}"
  end

  def self.credentials
    Rails.application.credentials.abstract
  end

  private_class_method :credentials
end
