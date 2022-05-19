# frozen_string_literal: true

namespace :audits do
  desc "Run Brakeman"
  task :brakeman do
    puts "Running brakeman"
    file = "audits/brakeman/index.html"
    sh "rm -fv #{file}"
    sh "brakeman -q -w2 -o #{file}"
    sh "open #{file}"
  end

  desc "Check Bundler Audit"
  task :bundle_audit do
    puts "Running bundler audit"
    file = "audits/bundler/index.json"
    sh "rm -fv #{file}"
    sh "bundle-audit --update --format json --output #{file}"
  end

  desc "Run Rails Best Practices"
  task :rails_best_practices do
    puts "Running rails best practices"
    file = "audits/rails_best_practices/index.html"
    sh "rails_best_practices -f html --output-file #{file} -e 'app/helpers,node_modules'"
    sh "open #{file}"
  end

  desc "Run Rubocop"
  task :rubocop do
    puts "Running rubocop"
    file = "audits/rubocop/index.html"
    sh "rm -fv #{file}"
    sh "rubocop --format html -o #{file} --format offenses --format progress --parallel"
    sh "open #{file}"
  end

  desc "Run Ruby Audit"
  task :ruby_audit do
    puts "Running ruby audit"
    sh "bundle exec ruby-audit check"
  end

  desc "Run Rails Tests"
  task :rails_tests do
    puts "Running tests"
    file = "audits/simplecov/index.html"
    sh "rm -fv #{file}"
    sh "bundle exec rails test"
    sh "open #{file}"
  end

  desc "Run all audits"
  task run: :environment do
    Rake::Task["audits:brakeman"].invoke
    Rake::Task["audits:bundle_audit"].invoke
    Rake::Task["audits:rails_best_practices"].invoke
    Rake::Task["audits:rubocop"].invoke
    Rake::Task["audits:ruby_audit"].invoke
    Rake::Task["audits:rails_tests"].invoke
  end
end

task :audits do
  puts "Audits Starting"
  Rake::Task["audits:run"].invoke
  puts "Audits Done"
end
