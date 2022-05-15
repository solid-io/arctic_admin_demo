# frozen_string_literal: true

class WebpushSubscriptionsController < ApplicationController
  def index
  end

  def create
    @device_token = AdminDeviceToken.find_or_create_by!({
      admin_user_id: AdminUser.first.id,
      enabled: true,
      token_type: "webpush",
      token: params[:webpush_subscriptions][:subscription][:keys][:auth],
      endpoint: params[:webpush_subscriptions][:subscription][:endpoint],
      expiration: params[:webpush_subscriptions][:subscription][:expiration],
      p256dh: params[:webpush_subscriptions][:subscription][:keys][:p256dh],
      os: params[:webpush_subscriptions][:client][:osName],
      browser: params[:webpush_subscriptions][:client][:browserName],
      user_agent: params[:webpush_subscriptions][:client][:browserAgent],
    })
    if @device_token.persisted?
      # render json: @device_token
      render json: { status: "ok" }
    else
      render json: @device_token.errors.full_messages
    end
  end
end
