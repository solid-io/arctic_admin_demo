class Schedule < ApplicationRecord
  belongs_to :scheduleable, polymorphic: true, optional: true
  has_many :rules, dependent: :destroy
  has_many :schedule_events
  accepts_nested_attributes_for :rules, allow_destroy: true

  after_initialize :set_defaults
  after_commit :send_update_notifications

  validates :capacity, :name, :time_zone, :beginning_of_week, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :lunch_hour_start, :lunch_hour_end, presence: true, if: :exclude_lunch_time?
  validate :lunch_hour_end_after_lunch_hour_start, if: :exclude_lunch_time?
  validates_inclusion_of :time_zone, in: ActiveSupport::TimeZone.us_zones.map(&:name)

  scope :active, -> { where(active: true)}

  def add_exception_rule_to_schedule(ice_cube_schedule, start_date, end_date=nil, start_time=nil, end_time=nil)
    case
    when start_date.present? && end_date.nil? && start_time.nil? && end_time.nil? && start_date >= Date.today
      add_exception_times(ice_cube_schedule, start_date)
    when start_date.present? && end_date.present? && start_time.nil? && end_time.nil? && end_date >= Date.today
      (start_date..end_date).each do |date|
        add_exception_times(ice_cube_schedule, date)
      end
    when start_date.present? && end_date.nil? && start_time.present? && end_time.present? && start_date >= Date.today
      add_exception_times(ice_cube_schedule, start_date, start_time, end_time)
    when start_date.present? && end_date.present? && start_time.present? && end_time.present? && end_date >= Date.today
      (start_date..end_date).each do |date|
        add_exception_times(ice_cube_schedule, date, start_time, end_time)
      end
    end
  end

  def add_exception_times(ice_cube_schedule, date, start_time=nil, end_time=nil)
    exceptions = ice_cube_schedule.occurrences_between(date.in_time_zone(time_zone).beginning_of_day, date.in_time_zone(time_zone).end_of_day)
    if !start_time.nil? && !end_time.nil?
      exceptions.each do |exception|
        if exception.start_time.strftime("%H:%M").between?(start_time, end_time)
          ice_cube_schedule.add_exception_time(exception.start_time)
        end
      end
    else
      exceptions.each { |exception| ice_cube_schedule.add_exception_time(exception.start_time) }
    end
  end

  def schedule_time_between_lunch_times(date)
    date.start_time.strftime("%H:%M").between?(self.lunch_hour_start, self.lunch_hour_end)
  end

  def build_scheduled_event(rule, date, friendly_frequency_units)
    ScheduleOutput.new(start_date: date.start_time.strftime("%Y-%m-%d"), kind_of_schedule: friendly_frequency_units, time_of_day: rule.get_time_of_day_description(date), start_time: date.start_time, capacity: self.capacity, availability: self.capacity)
  end

  def calculate_availability(scheduled_events)
    self.schedule_events.all.each do |event|
      appointment_count = event.medtest_location_appointments.count
      search_time = event.event_time
      found_event = scheduled_events.find_index{|se| se.start_time == search_time}
      if found_event
        scheduled_events[found_event].availability = scheduled_events[found_event].capacity - appointment_count
      end
    end
    scheduled_events
  end

  def handle_current_day_time_rejections(scheduled_events)
    scheduled_events.delete_if {|event| event.start_time < Time.now.in_time_zone(time_zone).to_time}
  end

  def handle_rule_minute_rejections(scheduled_events)
    scheduled_events.delete_if {|event| event.start_time < included.rule_date_with_time(included.start_date, included.rule_hour_start)}
  end

  def get_scheduled_events
    return nil unless rules.inclusion.present?
    @schedules_array = []

    # build array of schedules from the inclusion rules
    rules.inclusion.each do |included|
      if included.start_date > Date.today
        included_start_date = included.rule_date_with_time(included.start_date, included.rule_hour_start)
      else
        included_start_date = included.rule_date_with_time(Date.today, included.rule_hour_start)
      end
      # included_start_date = included.rule_date_with_time(included.start_date, included.rule_hour_start)
      included_end_date = included.rule_date_with_time(included.end_date, included.rule_hour_end)
      ice_cube_schedule = IceCube::Schedule.new(included_start_date, :end_time => included_end_date)
      ice_cube_schedule.add_recurrence_rule included.generate_rule_from_hash
      @schedules_array << ice_cube_schedule
    end

    # process exclusion rules for each inclusion rule
    if rules.exclusion.present? && rules.exclusion.pluck(:start_date).max >= Date.today
      @schedules_array.each do |ice_cube_schedule|
        rules.exclusion.each do |excluded|
          excluded_start_date = excluded.start_date.in_time_zone(time_zone).to_date
          excluded_end_date   = excluded.end_date.in_time_zone(time_zone).to_date if excluded.end_date.present?
          excluded_start_time = excluded.rule_hour_start if excluded.rule_hour_start.present?
          excluded_end_time   = excluded.rule_hour_end if excluded.rule_hour_end.present?
          add_exception_rule_to_schedule(ice_cube_schedule, excluded_start_date, excluded_end_date, excluded_start_time, excluded_end_time)
        end
      end
    end

    # build scheduled events array of objects for simple calendar
    scheduled_events =[]
    rules.inclusion.each_with_index do |rule, index|
      rule_start_date = rule.start_date.in_time_zone(time_zone).beginning_of_day
      #rule.rule_date_with_time(rule.start_date, rule.rule_hour_start)
      #
      rule_end_date = rule.end_date.in_time_zone(time_zone).end_of_day
      #rule.rule_date_with_time(rule.end_date, rule.rule_hour_end)

      friendly_frequency_units ||= rule.friendly_frequency_units(rule.frequency_units)
      @schedules_array[index].occurrences_between(rule_start_date, rule_end_date).map do |date|
        if self.exclude_lunch_time?
          unless schedule_time_between_lunch_times(date)
            if rule.rule_hour_start.to_time.min != 0 || rule.rule_hour_end.to_time.min != 0
              if rule.rule_date_with_time(date, date.to_time.strftime("%H:%M")) >= rule.rule_date_with_time(date, rule.rule_hour_start) && rule.rule_date_with_time(date, date.to_time.strftime("%H:%M")) <= rule.rule_date_with_time(date, rule.rule_hour_end)
                scheduled_events << build_scheduled_event(rule, date, friendly_frequency_units)
              end
            else
              scheduled_events << build_scheduled_event(rule, date, friendly_frequency_units)
            end
          end
        else
          if rule.rule_hour_start.to_time.min != 0 || rule.rule_hour_end.to_time.min != 0
            if rule.rule_date_with_time(date, date.to_time.strftime("%H:%M")) >= rule.rule_date_with_time(date, rule.rule_hour_start) && rule.rule_date_with_time(date, date.to_time.strftime("%H:%M")) <= rule.rule_date_with_time(date, rule.rule_hour_end)
              scheduled_events << build_scheduled_event(rule, date, friendly_frequency_units)
            end
          else
            scheduled_events << build_scheduled_event(rule, date, friendly_frequency_units)
          end
        end
      end
    end
    calculate_availability(scheduled_events)
    handle_current_day_time_rejections(scheduled_events)
  end

  def add_holidays(schedule)
    schedule.current_holidays.each {|holiday| schedule.rules.create(rule_type: "exclusion", name: holiday[1], start_date: holiday[0])}
  end

  def remove_holidays(schedule)
    schedule.rules.exclusion.each do |rule|
      if Schedule::NATIONAL_HOLIDAYS.has_key?(rule.start_date.to_s) && Schedule::NATIONAL_HOLIDAYS.invert.has_key?(rule.name) && rule.end_date.nil? && rule.rule_hour_start.blank? && rule.rule_hour_end.blank?
          rule.destroy
      end
    end
  end

  def current_holidays
    Schedule::NATIONAL_HOLIDAYS.select { |key, value| key.to_date.between?(Date.today, rules.inclusion.pluck(:end_date).max) }
  end

  def schedule_holiday_rule_exits?
    (rules.exclusion.pluck(:name).uniq & Schedule::NATIONAL_HOLIDAYS.invert.keys).any?
  end

  # https://www.opm.gov/policy-data-oversight/pay-leave/federal-holidays
  NATIONAL_HOLIDAYS = {
    "2021-01-01" => "New Year's Day",
    "2021-01-18" => "Birthday of Martin Luther King, Jr.",
    "2021-01-20" => "Inauguration Day",
    "2021-02-15" => "Washington's Birthday",
    "2021-05-31" => "Memorial Day",
    "2021-06-18" => "Juneteenth National Independence Day",
    "2021-07-05" => "Independence Day",
    "2021-09-06" => "Labor Day",
    "2021-10-11" => "Columbus Day",
    "2021-11-11" => "Veterans Day",
    "2021-11-25" => "Thanksgiving Day",
    "2021-12-24" => "Christmas Day",

    "2021-12-31" => "New Year's Day",
    "2022-01-17" => "Birthday of Martin Luther King, Jr.",
    "2022-02-21" => "Washington's Birthday",
    "2022-05-30" => "Memorial Day",
    "2022-06-04" => "Independence Day",
    "2022-09-05" => "Labor Day",
    "2022-10-10" => "Columbus Day",
    "2022-11-11" => "Veterans Day",
    "2022-11-24" => "Thanksgiving Day",
    "2022-12-26" => "Christmas Day",

    "2023-01-02" => "New Year's Day",
    "2023-01-16" => "Birthday of Martin Luther King, Jr.",
    "2023-02-20" => "Washington's Birthday",
    "2023-05-29" => "Memorial Day",
    "2023-07-04" => "Independence Day",
    "2023-09-04" => "Labor Day",
    "2023-10-09" => "Columbus Day",
    "2023-11-10" => "Veterans Day",
    "2023-11-23" => "Thanksgiving Day",
    "2023-12-25" => "Christmas Day",

    "2024-01-01" => "New Year's Day",
    "2024-01-15" => "Birthday of Martin Luther King, Jr.",
    "2024-02-19" => "Washington's Birthday",
    "2024-05-27" => "Memorial Day",
    "2024-07-04" => "Independence Day",
    "2024-09-02" => "Labor Day",
    "2024-10-14" => "Columbus Day",
    "2024-11-11" => "Veterans Day",
    "2024-11-28" => "Thanksgiving Day",
    "2024-12-25" => "Christmas Day",

    "2025-01-01" => "New Year's Day",
    "2025-01-20" => "Birthday of Martin Luther King, Jr. / Inauguration Day",
    "2025-02-17" => "Washington's Birthday",
    "2025-05-26" => "Memorial Day",
    "2025-07-04" => "Independence Day",
    "2025-09-01" => "Labor Day",
    "2025-10-13" => "Columbus Day",
    "2025-11-11" => "Veterans Day",
    "2025-11-27" => "Thanksgiving Day",
    "2025-12-25" => "Christmas Day",

    "2026-01-01" => "New Year's Day",
    "2026-01-18" => "Birthday of Martin Luther King, Jr.",
    "2026-02-15" => "Washington's Birthday",
    "2026-05-31" => "Memorial Day",
    "2026-07-05" => "Independence Day",
    "2026-09-06" => "Labor Day",
    "2026-10-11" => "Columbus Day",
    "2026-11-11" => "Veterans Day",
    "2026-11-25" => "Thanksgiving Day",
    "2026-12-24" => "Christmas Day",

    "2027-01-01" => "New Year's Day",
    "2027-01-18" => "Birthday of Martin Luther King, Jr.",
    "2027-02-15" => "Washington's Birthday",
    "2027-05-31" => "Memorial Day",
    "2027-07-05" => "Independence Day",
    "2027-09-06" => "Labor Day",
    "2027-10-11" => "Columbus Day",
    "2027-11-11" => "Veterans Day",
    "2027-11-25" => "Thanksgiving Day",
    "2027-12-24" => "Christmas Day",
    "2027-12-31" => "New Year's Day",

    "2028-01-17" =>  "Birthday of Martin Luther King, Jr.",
    "2028-02-21" => "Washington's Birthday",
    "2028-05-29" => "Memorial Day",
    "2028-07-04" => "Independence Day",
    "2028-09-04" => "Labor Day",
    "2028-10-09" => "Columbus Day",
    "2028-11-10" => "Veterans Day",
    "2028-11-23" => "Thanksgiving Day",
    "2028-12-25" => "Christmas Day",

    "2029-01-01" => "New Year's Day",
    "2029-01-15" => "Birthday of Martin Luther King, Jr.",
    "2029-02-19" => "Washington's Birthday",
    "2029-05-28" => "Memorial Day",
    "2029-07-04" => "Independence Day",
    "2029-09-03" =>"Labor Day",
    "2029-10-08" => "Columbus Day",
    "2029-11-12" => "Veterans Day",
    "2029-11-22" => "Thanksgiving Day",
    "2029-12-25" => "Christmas Day",

    "2030-01-01" => "New Year's Day",
    "2030-01-21" => "King Jr.'s Birthday",
    "2030-02-18" => "Washington's Birthday",
    "2030-05-27" => "Memorial Day",
    "2030-07-04" => "Independence Day",
    "2030-09-02" => "Labor Day",
    "2030-10-14" => "Columbus Day",
    "2030-11-11" => "Veterans Day",
    "2030-11-28" => "Thanksgiving Day",
    "2030-12-25" => "Christmas Day",
  }.freeze

  def send_update_notifications
    ScheduleMailer.update.deliver_now
  end
  private

  def set_defaults
    self.capacity ||= 25
    # self.time_zone ||= LocationProduct.find(self.scheduleable_id).location.time_zone if self.scheduleable_id.present?
    self.beginning_of_week ||= "sunday"
  end

  def lunch_hour_end_after_lunch_hour_start
    if self.lunch_hour_start.present? && self.lunch_hour_end.present? && self.lunch_hour_end&.to_time <= self.lunch_hour_start&.to_time
      errors.add(:lunch_hour_end, "must be after start time")
    end
  end
end