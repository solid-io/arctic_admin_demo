ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  # content title: proc { I18n.t("active_admin.dashboard") } do
  # div class: "blank_slate_container", id: "dashboard_default_message" do
  #   span class: "blank_slate" do
  #     span I18n.t("active_admin.dashboard_welcome.welcome")
  #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
  #   end
  # end
  # end # content

  REPORTS = %w[AdminUsers Companies Locations Schedules]

  content do
    panel "Welcome to System ADD_USER_NAME | #{current_admin_user.email}" do
      para "Welcome to..."
    end

    columns do
      column  do
        panel "Reports" do
          table do
            REPORTS.each do |report|
              tr do
                td do
                  link_to("#{report}", "/admin/#{report.tableize}")
                end
              end
            end
          end
        end
      end
      column span: 2 do
        # span "Column # 2"
        panel "Recent Companies" do
          ul do
            Company.all.map do |company|
              li link_to(company.name, admin_company_path(company))
            end
          end
        end
      end
    end
  end
end
