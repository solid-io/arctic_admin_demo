# frozen_string_literal: true

# To deliver this notification:
#
# UserNotification.with(post: @post).deliver_later(current_user)
# UserNotification.with(post: @post).deliver(current_user)
#   UserNotification.with(user: @user).deliver(@user)

class UserNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  # deliver_by :email, mailer: "UserMailer"
  deliver_by :webpush, class: "DeliveryMethods::Webpush"
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  param :user

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end
end
