# frozen_string_literal: true

class ScheduleOutput
  include ActiveModel::Model

  attr_accessor :start_date, :kind_of_schedule, :time_of_day, :start_time, :capacity, :availability
end
