# frozen_string_literal: true

desc "Run all audits | rails audits -- --open=true --rubocop=true"
task :audits do |task|
  if Rails.env.development?
    options = { open: nil, auto: nil }
    option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: rake audit [options]"
      opts.on("-o", "--open TRUE") { |o| options[:open] = o }
      opts.on("-r", "--rubocop TRUE") { |r| options[:rubocop] = r }
    end

    args = option_parser.order!(ARGV) { }
    option_parser.parse!(args)

    @open_reports = options[:open].nil? ? false : true
    @rubocop_auto_correct = options[:rubocop].nil? ? "" : "-A"
    @task_name = task.name
    @start_at = Time.now
    @files = [
      { brakeman: "audits/brakeman/index.html" },
      { bundle_audit: "audits/bundler/index.json" },
      { rails_best_practices: "audits/rails_best_practices/index.html" },
      { rubocop: "audits/rubocop/index.html" },
      { ruby_audit: "audits/ruby_audit/index.html" },
      { rails_erd: "audits/erd/index.pdf" },
      { rails_tests: "audits/simplecov/index.html" }
    ]

    LOG_LEVEL_LABEL = %w[DEBUG INFO WARN ERROR FATAL ANY].freeze

    def log_level_text(log_level)
      LOG_LEVEL_LABEL[log_level] || "ANY"
    end

    def log_and_show(log, log_level, message)
      log.add log_level, message.chomp
      puts "** [task] #{log_level_text(log_level)}: #{message}"
    end

    def start_logging(start_time = Time.zone.now, log_file = "log/audits.log")
      log = ActiveSupport::Logger.new(log_file)
      log_and_show log, Logger::INFO, "Task #{@task_name} with open=#{@open_reports} started at #{start_time}"
      log
    end

    def filepath(key)
      @files.select { |file| file[key] }.first.values.first
    end

    def brakeman
      log_and_show @log, Logger::INFO, "Running brakeman"
      sh "brakeman -q -w2 -o #{filepath(:brakeman)}", verbose: false
      rescue StandardError => e
        log_and_show @log, Logger::ERROR, "Error running brakeman: #{e.message}"
    end

    def bundle_audit
      log_and_show @log, Logger::INFO, "Running bundle audit"
      sh "bundle-audit --update --format json --output #{filepath(:bundle_audit)}", verbose: false
      rescue StandardError => e
        log_and_show @log, Logger::ERROR, "Error running bundle-audit: #{e.message}"
    end

    def erd
      log_and_show @log, Logger::INFO, "Running rails erd"
      sh "erd", verbose: false
    end

    def rails_best_practices
      log_and_show @log, Logger::INFO, "Running rails best practice"
      sh "rails_best_practices -f html --output-file #{filepath(:rails_best_practices)} -e 'app/helpers,node_modules'", verbose: false
      rescue StandardError => e
        log_and_show @log, Logger::ERROR, "Error running rails_best_practices: #{e.message}"
    end

    def ruby_audit
      log_and_show @log, Logger::INFO, "Running ruby audit"
      sh "ruby-audit check", verbose: false
    end

    def rubocop
      log_and_show @log, Logger::INFO, "Running rubocop"
      sh "rubocop --format html -o #{filepath(:rubocop)} --format offenses --format progress --parallel", verbose: false
      rescue StandardError => e
        log_and_show @log, Logger::ERROR, "Error running rubocop: #{e.message}"
        sh "rm -fv #{filepath(:rubocop)}" if @rubocop_auto_correct.present?
        sh "rubocop #{@rubocop_auto_correct} --format html -o #{filepath(:rubocop)} --format offenses --format progress", verbose: false if @rubocop_auto_correct.present?
    end

    def rails_tests
      log_and_show @log, Logger::INFO, "Running tests"
      sh "rails test", verbose: false
      rescue StandardError => e
        log_and_show @log, Logger::ERROR, "Error running rails test: #{e.message}"
    end

    def reports
      log_and_show @log, Logger::INFO, "Opening Reports in Browser"
      @files.flat_map { |x| x.values }.reject { |x| x == "audits/bundler/index.json" }.each do |file|
        sh "open #{file}", verbose: false if ActiveModel::Type::Boolean.new.cast(@open_reports)
        rescue StandardError => e
          log_and_show @log, Logger::ERROR, "Error opening report file:#{file} error: #{e.message}"
      end
    end

    def finish
      end_at = Time.now
      less_than_minute = (end_at - @start_at) < 60
      duration = (end_at - @start_at) < 60 ? (end_at - @start_at).to_i : ((end_at - @start_at) / 60.seconds).to_i
      log_and_show @log, Logger::INFO, "Task #{@task_name} with open=#{@open_reports} finished at #{end_at} | Duration: #{duration} #{less_than_minute ? 'seconds' : 'minutes'}"
    end

    @log = start_logging(@start_at)

    brakeman
    bundle_audit
    erd
    rails_best_practices
    rubocop
    ruby_audit
    rails_tests
    reports
    finish

  end
end
