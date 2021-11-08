module ApplicationHelper

  def user_avatar(user, size=40)
    if user.avatar.attached?
      # user.avatar.variant(resize_to_limit: ["#{size}", "#{size}"]).processed.url
      url_for(user.avatar.variant(resize_to_limit: ["#{size}", "#{size}"]).processed)
    end
  end
end
