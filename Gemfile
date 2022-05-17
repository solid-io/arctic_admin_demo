# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails", "~> 6.1.4", ">= 6.1.4.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use Puma as the app server
gem "puma", "~> 5.6"
# Use SCSS for stylesheets
gem "sass-rails", ">= 6"
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem "webpacker", "~> 5.0"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem "image_processing", "~> 1.2"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.4.4", require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "pry"
  gem "faker"                                  # https://github.com/faker-ruby/faker
  gem "shoulda"                                # https://github.com/thoughtbot/shoulda
  gem "simplecov", require: false              # https://github.com/simplecov-ruby/simplecov
  gem "rubocop-rails", require: false          # https://github.com/rubocop/rubocop-rails
  gem "rubocop-minitest", require: false       # https://github.com/rubocop/rubocop-minitest
  gem "rubocop-packaging"                      # https://github.com/utkarsh2102/rubocop-packaging
  gem "rubocop-performance", require: false    # https://github.com/rubocop/rubocop-performance
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 4.1.0"
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem "rack-mini-profiler", "~> 2.0"
  gem "listen", "~> 3.3"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "annotate"                               # https://github.com/ctran/annotate_models
  gem "brakeman"                               # https://github.com/presidentbeef/brakeman
  gem "bundler-audit"                          # https://github.com/rubysec/bundler-audit
  gem "ruby_audit"                             # https://github.com/civisanalytics/ruby_audit
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 3.26"
  gem "selenium-webdriver"
  # Easy installation and use of web drivers to run system tests with browsers
  gem "webdrivers"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "activeadmin"                             # https://activeadmin.info/documentation.html
gem "devise"                                  # https://github.com/heartcombo/devise
gem "arctic_admin"                            # https://github.com/cprodhomme/arctic_admin
gem "ice_cube"                                # https://github.com/ice-cube-ruby/ice_cube
gem "simple_calendar"                         # https://github.com/excid3/simple_calendar
gem "activeadmin_dynamic_fields"               # https://github.com/blocknotes/activeadmin_dynamic_fields
gem "activeadmin_addons"                      # https://github.com/platanus/activeadmin_addons
gem "country_select"                          # https://github.com/countries/country_select
gem "telephone_number"                        # https://github.com/mobi/telephone_number
gem "webpush"                                 # https://github.com/zaru/webpush
gem "noticed"                                 # https://github.com/excid3/noticed
gem "faraday"                                 # https://github.com/lostisland/faraday
gem "faraday_middleware"                      # https://github.com/lostisland/faraday
gem "name_of_person"                          # https://github.com/basecamp/name_of_person
gem "net-smtp", require: false                # https://github.com/ruby/net-smtp # https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
gem "net-pop", require: false                 # https://github.com/ruby/net-pop  # https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
gem "net-imap", require: false                # https://github.com/ruby/net-imap # https://stackoverflow.com/questions/70500220/rails-7-ruby-3-1-loaderror-cannot-load-such-file-net-smtp
