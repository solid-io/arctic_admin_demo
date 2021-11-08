ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    #    div :class => "blank_slate_container", :id => "dashboard_default_message" do
    #      span :class => "blank_slate" do
    #        span "Welcome to Active Admin. This is the default dashboard page."
    #        small "To add dashboard sections, checkout 'app/admin/dashboards.rb'"
    #      end
    #    end

    columns do
      column do

          # records_aura_db = ActiveRecord::Base.connection.execute("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE != 'BASE TABLE' AND TABLE_CATALOG = '#{Rails.configuration.database_configuration[Rails.env]['database']}'")
          # distinct =  ActiveRecord::Base.connection.execute("SELECT DISTINCT(TABLE_NAME) FROM INFORMATION_SCHEMA.TABLES")
          # actual =  ActiveRecord::Base.connection.execute("SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'locations'")
        records =  ActiveRecord::Base.connection.execute("SELECT relname,n_live_tup FROM pg_stat_user_tables ORDER BY n_live_tup DESC")
          # records = ActiveRecord::Base.connection.tables
#         records = ActiveRecord::Base.connection.execute("
#           SELECT TABLE_NAME, TABLE_ROWS
#           FROM INFORMATION_SCHEMA.TABLES
#           WHERE TABLE_SCHEMA = '#{Rails.configuration.database_configuration[Rails.env]['database']}'
#           order by TABLE_ROWS DESC;")
        all_models_count = records.collect{ |row| [row['relname'], row['n_live_tup'].to_i]}
        max = all_models_count.first[1].to_f
        percent = 100.00/max

        panel "Database Records" do
          recs = ''
          all_models_count.each do |model_name, count|
            bar_size = percent*count
            bar_size = 2 if bar_size < 2 and bar_size > 0

            recs << "<div width='100px'>"
            recs << link_to("#{model_name.tableize} - #{count}", "/admin/#{model_name.tableize}") rescue nil
            recs << "<div class=\"progress progress-info\">"
            recs << "<div class=\"bar\" style=\"width: #{bar_size}%\">"
            recs << "</div>"
            recs << "</div>"
            recs << "</div>"
          end
          recs.html_safe
        end
      end

      column do
        panel "Info" do
          para "Welcome to ActiveAdmin."
        end

      end
    end
  end
end