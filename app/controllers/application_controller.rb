class ApplicationController < ActionController::Base
  around_action :set_time_zone, if: :current_admin_user

  private
    def set_time_zone(&block)
      Time.use_zone(current_admin_user.time_zone, &block)
    end
end
