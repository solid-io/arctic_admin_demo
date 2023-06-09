# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  coverage_dir "audits/simplecov/"
  add_group "Active Admin", ["/app/admin/"]
  add_group "Model",        "app/model"
  add_group "Controllers",  "app/controllers"
  add_group "Helpers",      "app/helpers"
  add_group "Jobs",         "app/jobs"
  add_group "Mailers",      "app/mailers"
  add_group "Serializers",  "app/serializers"
  add_group "Policies",     "app/policies"
  add_group "Views",        "app/views"
  add_group "Libraries",    "lib"
  add_group "Notifications", "app/notifications"
  add_group "Services",     "app/services"
end
Rails.application.eager_load!

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
