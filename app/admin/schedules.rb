ActiveAdmin.register Schedule do
  menu parent: "Organization"

  # config.remove_action_item(:new)

  permit_params :active, :beginning_of_week, :capacity, :company_id, :exclude_lunch_time, :lunch_hour_start,
                :lunch_hour_end, :name, :scheduleable_id, :scheduleable_type, :start_date, :time_zone, {:user_types => []},
                rules_attributes: [:id, :name, :rule_type, :frequency_units, :frequency, {:days_of_week => []},
                                   :start_date, :end_date, :rule_hour_start, :rule_hour_end, :_destroy]

  controller do
    before_action :set_beginning_of_week, only: [:show]
    before_action :load_events, only: [:show]

    def scoped_collection
      Schedule.includes(:rules)
    end

    def set_beginning_of_week
      Date.beginning_of_week = resource.beginning_of_week.to_sym
    end

    def create
      super do |format|
        format.html { redirect_to edit_admin_schedule_path resource.id }
      end
    end

    def load_events
      if params[:start_date]
        start_date = params[:start_date].to_date.beginning_of_month - params[:start_date].to_date.beginning_of_month.wday
        @events ||= resource.get_scheduled_events.select { |item| item.start_date.to_date.between?(start_date.beginning_of_week, (start_date + 35.days).end_of_week )  }
      else
        @events ||= resource.get_scheduled_events
      end
    end
  end

  batch_action :activate do |ids|
    batch_action_collection.find(ids).each do |schedule|
      schedule.active = true
      schedule.save
    end
    redirect_to collection_path, alert: "The schedules have been activated."
  end

  batch_action :inactivate do |ids|
    batch_action_collection.find(ids).each do |schedule|
      schedule.active = false
      schedule.save
    end
    redirect_to collection_path, alert: "The schedules have been inactivated."
  end

  batch_action :clone, confirm: "Do you want to include close times?", form: {no: :checkbox} do |ids, inputs|
    batch_action_collection.find(ids).each do |schedule|
      @schedule = schedule.dup
      @schedule.name = "UPDATE ME..."
      @schedule.active = false
      @schedule.save
      if inputs["no"] == "on"
        @schedule.rules << schedule.rules.inclusion.map(&:dup)
      else
        @schedule.rules << schedule.rules.map(&:dup)
      end
    end
    redirect_to collection_path, alert: "The schedules have been cloned."
  end

  batch_action :add_holidays do |ids|
    batch_action_collection.find(ids).each do |schedule|
      schedule.add_holidays(schedule)
    end
    redirect_to collection_path, alert: "The schedules have had holidays added."
  end

  batch_action :remove_holidays do |ids|
    batch_action_collection.find(ids).each do |schedule|
      schedule.remove_holidays(schedule)
    end
    redirect_to collection_path, alert: "The schedules have had holidays removed."
  end

  member_action :add_holiday_exlusions, method: :get do
    resource.add_holidays(resource)
    redirect_to admin_schedule_path(params[:id])
  end

  member_action :refresh_holiday_exlusions, method: :get do
    resource.remove_holidays(resource)
    resource.add_holidays(resource)
    redirect_to admin_schedule_path(params[:id])
  end

  member_action :remove_holiday_exlusions, method: :get do
    resource.remove_holidays(resource)
    redirect_to admin_schedule_path(params[:id])
  end

  member_action :save, method: :post do
    ActiveAdmin::DynamicFields.update(resource,  params, [:active, :exclude_lunch_time, :beginning_of_week])
    redirect_to admin_schedule_path(params[:id])
  end

  filter :id
  filter :name, input_html: { autocomplete: 'off' }
  filter :active
  filter :capacity
  # filter :user_types, as: :select,
  #       collection: proc { current_admin_user.user_types.ordered }
  filter :exclude_lunch_time
  filter :time_zone, as: :select,
        collection: proc { Schedule.all.pluck(:time_zone).uniq }
  filter :beginning_of_week, as: :select,
        collection: Rule::DAYS_OF_WEEK.slice("Sunday", "Monday")

  # partials located in default location views/admin/schedules
  index do
    render partial: 'index', locals:{context: self}
  end

  form partial: "form"

  show do
    render partial: 'show', locals:{context: self}
  end

  csv do
    column :id
    column :scheduleable_id
    column :scheduleable_type
    column :name
    column :active
    column :capacity
    # column(:user_types) { |schedule| UserType.where(id: schedule.user_types).ordered.pluck(:name).join(", ") }
    column :exclude_lunch_time
    column(:lunch_hour_start) { |schedule| schedule.lunch_hour_start&.to_time&.strftime("%I:%M %P") }
    column(:lunch_hour_end) { |schedule| schedule.lunch_hour_end&.to_time&.strftime("%I:%M %P") }
    column :time_zone
    column(:beginning_of_week) { |schedule| schedule.beginning_of_week.titleize }
    column(:rules) { |schedule| schedule.rules.map(&:name).join(', ') }
    column(:holidays) { |schedule| schedule.schedule_holiday_rule_exits? }
    column :created_at
    column :updated_at
  end

end