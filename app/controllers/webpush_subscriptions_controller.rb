# frozen_string_literal: true

class WebpushSubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
  end

  def create
    @device_token = AdminDeviceToken.find_or_create_by!({
      admin_user_id: client[:admin_user_id],
      enabled: true,
      token_type: "webpush",
      token: subscription[:keys][:auth],
      endpoint: subscription[:endpoint],
      expiration: subscription[:expiration],
      p256dh: subscription[:keys][:p256dh],
      os: client[:osName],
      browser: client[:browserName],
      user_agent: client[:browserAgent],
    })
    if @device_token.persisted?
      # render json: @device_token
      render json: { status: :created }
    else
      render json: @device_token.errors.full_messages, status: :unprocessable_entity
    end
  end


  private

    def webpush_subscriptions_params
      params.require(:webpush_subscriptions).permit(subscription: [:endpoint, :expirationTime, keys: [:p256dh, :auth]], client: [:browserName, :browserVersion, :browserMajorVersion, :objappVersion, :browserAgent, :osName, :admin_user_id])
    end

    def subscription
      webpush_subscriptions_params[:subscription]
    end

    def client
      webpush_subscriptions_params[:client]
    end

end