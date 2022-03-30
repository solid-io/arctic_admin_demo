# frozen_string_literal: true

class Rule < ApplicationRecord
  belongs_to :schedule, touch: true

  RULE_TYPE = {
    "Open times" => "inclusion",
    "Close times" => "exclusion",
  }.freeze
  FREQUENCY_UNITS = {
    "Minutely" => "IceCube::MinutelyRule",
    "Daily" => "IceCube::DailyRule",
    "Weekly" => "IceCube::WeeklyRule",
    "Monthly" => "IceCube::MonthlyRule",
    "Yearly" => "IceCube::YearlyRule",
  }.freeze
  DAYS_OF_WEEK = {
    "Sunday" => "sunday",
    "Monday" => "monday",
    "Tuesday" => "tuesday",
    "Wednesday" => "wednesday",
    "Thursday" => "thursday",
    "Friday" => "friday",
    "Saturday" => "saturday",
  }.freeze

  after_initialize :set_defaults
  before_save :set_defaults_exlusion, unless: :inclusion?

  validates :name, :rule_type, :start_date, presence: true
  with_options if: :inclusion? do |inclusion|
    inclusion.validates :frequency_units, :frequency, :days_of_week, :end_date, :rule_hour_start, :rule_hour_end, presence: true
    inclusion.validates :frequency, numericality: { greater_than: 0 }
    inclusion.validate :end_date_after_start_date
  end
  validate :end_date_after_start_date, if: :end_date?
  validates :rule_hour_end, presence: true, if: :rule_hour_start?
  validate :rule_hour_end_after_rule_hour_start, if: :rule_hour_end?
  validate :no_exlusion_without_inclusion, unless: :inclusion?
  # TODO-242: Validate frequency range for each frequency_unit - day can only be used with multiples of interval(7)

  default_scope { order(rule_type: :desc, start_date: :asc) }
  scope :inclusion, -> { where(rule_type: "inclusion") }
  scope :exclusion, -> { where(rule_type: "exclusion") }

  def inclusion?
    self.rule_type == "inclusion"
  end

  def frequency_units_minute?
    self.frequency_units == "IceCube::MinutelyRule"
  end

  def friendly_frequency_units(frequency_units)
    return "" if !inclusion?
    frequency_units == "IceCube::DailyRule" ? "Day" : Rule::FREQUENCY_UNITS.invert[frequency_units].chomp("ly")
  end

  def friendly_frequency(frequency, frequency_units)
    return "" unless inclusion?
    frequency_units == "IceCube::MinutelyRule" ? "Every #{frequency} #{friendly_frequency_units(frequency_units).pluralize}" : "Every #{frequency.ordinalize} #{friendly_frequency_units(frequency_units)}"
  end

  def time_zone
    self.schedule.time_zone
  end

  def time_in_zone(time)
    time.in_time_zone(time_zone)
  end

  def rule_date_with_time(date, time)
    date.to_time.in_time_zone(self.time_zone).to_time.change({ hour: time.to_time.hour, min: time.to_time.min, sec: 0 })
  end

  def get_time_of_day_description(date)
    case
    when date.start_time.strftime("%H:%M").between?("00:00", "11:59")
      "morning"
    when date.start_time.strftime("%H:%M").between?("12:00", "16:59 pm")
      "afternoon"
    when date.start_time.strftime("%H:%M").between?("17:00 pm", "23:59 pm")
      "evening"
    end
  end

  def generate_rule_from_hash
    IceCube::Rule.from_hash convert_rule_hash
  end

  def convert_rule_hash
    [convert_days, convert_frequency_units, convert_frequency].inject(&:merge)
  end

  def convert_hours_of_day
    splat_hour_array = *(time_in_zone(self.rule_hour_start).hour...time_in_zone(self.rule_hour_end).hour)
    if time_in_zone(self.rule_hour_end).hour == 23 && time_in_zone(self.rule_hour_end).min > 0
      splat_hour_array << time_in_zone(self.rule_hour_end).hour
    end
    splat_hour_array
  end

  def convert_days_of_week
    self.days_of_week.map(&:to_sym)
  end

  def convert_days
    self.frequency_units_minute? ? { validations: { hour_of_day: convert_hours_of_day, day: convert_days_of_week } } : { validations: { day: convert_days_of_week } }
  end

  def convert_frequency_units
    { rule_type: self.frequency_units }
  end

  def convert_frequency
    { interval: self.frequency }
  end

  private
    def set_defaults
      self.rule_type ||= "inclusion"
      self.frequency_units ||= "IceCube::MinutelyRule"
      self.frequency ||= 15 if inclusion?
      self.start_date ||= Date.today
    end

    def set_defaults_exlusion
      self.frequency_units = ""
      self.frequency = nil
      self.days_of_week = []
    end

    def no_exlusion_without_inclusion
      if self.new_record? && !self.schedule.rules.inclusion.exists?
        errors.add(:rule_type, "must have at least one 'Open times' rule")
      end
    end

    def end_date_after_start_date
      if self.end_date <= self.start_date
        self.inclusion? ? errors.add(:end_date, "must be after start date") : errors.add(:end_date, "can be blank or must be after start date if selected")
      end
    end

    def rule_hour_end_after_rule_hour_start
      if self.rule_hour_end <= self.rule_hour_start
        errors.add(:rule_hour_end, "must be after start time")
      end
    end
end
