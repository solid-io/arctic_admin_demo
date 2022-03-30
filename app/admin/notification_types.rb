# frozen_string_literal: true

ActiveAdmin.register NotificationType do
  menu label: "Notification Types", parent: ["Administration", "Notifications"]

  permit_params :name, :email_enabled, :mailer, :email, :push_enabled, :push_summary, :push_details, :sms_enabled, :sms_body

  batch_action :toggle_email_enabled do |ids|
    batch_action_collection.find(ids).each do |notification_type|
      notification_type.email_enabled = !notification_type.email_enabled
      notification_type.save
    end
    redirect_to collection_path, alert: "The notification types email enabled status has been toggled."
  end

  batch_action :toggle_push_enabled do |ids|
    batch_action_collection.find(ids).each do |notification_type|
      notification_type.push_enabled = !notification_type.push_enabled
      notification_type.save
    end
    redirect_to collection_path, alert: "The notification types push enabled status has been toggled."
  end

  batch_action :toggle_sms_enabled do |ids|
    batch_action_collection.find(ids).each do |notification_type|
      notification_type.sms_enabled = !notification_type.sms_enabled
      notification_type.save
    end
    redirect_to collection_path, alert: "The notification types sms enabled status has been toggled."
  end

  member_action :disable_help, method: :get do
    current_admin_user.admin_user_help_preferences.where(controller_name: controller_name).first.update!(enabled: false)
    redirect_to send("edit_admin_#{controller_name.singularize}_path", params[:id]), notice: "You set the hide help admin user preference for #{controller_name.humanize}."
  end

  filter :id
  filter :name, input_html: { autocomplete: "off" }
  filter :email_enabled
  filter :mailer, as: :select,
        collection: proc { NotificationType.all.pluck(:mailer).uniq }
  filter :email, as: :select,
        collection: proc { NotificationType.all.pluck(:email).uniq }
  filter :push_enabled
  filter :push_summary
  filter :push_details
  filter :sms_enabled
  filter :sms_body
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :name
    column :email_enabled
    column(:mailer_and_email) { |notification_type| notification_type.mailer_email_present ? notification_type.preview.present? ? link_to(notification_type.mailer_emails_by_email, "#{request.base_url}/rails/mailers#{notification_type.mailer == "DeviseMailer" ? "/devise/mailer/" : "/"}#{notification_type.mailer.underscore}/#{notification_type.email}", { target: :_blank }) : notification_type.mailer_emails_by_email : "" }
    column :push_enabled
    column :sms_enabled
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    tabs do
       tab "Notification Details" do
         f.inputs do
           f.input :name
         end
       end
       tab "Rails Mailers" do
         f.inputs do
           f.input :email_enabled
           f.input :mailer, as: :select,
                   collection: NotificationType::CLASSIFIED_MAILERS,
                   allow_blank: true
           f.input :email, as: :select,
                   collection: f.object.emails,
                   allow_blank: true
         end
       end
       tab "Mobile Push" do
         f.inputs do
           f.input :push_enabled
           f.input :push_summary
           f.input :push_details
         end
       end
       tab "SMS Text" do
         f.inputs do
           f.input :sms_enabled
           f.input :sms_body
         end
       end
     end
    f.actions
  end

  sidebar :help, only: :edit, if: proc { current_admin_user.admin_user_help_preferences.where(controller_name: controller_name).presence ? current_admin_user.admin_user_help_preferences.where(controller_name: controller_name).first.enabled : true }  do
    div do
      h5 "Need help? Email us at help@example.com"
      render partial: "sidebar", locals: { context: self }
      if current_admin_user.admin_user_help_preferences.where(controller_name: controller_name).presence
        div do
          link_to("Hide", send("disable_help_admin_#{controller_name.singularize}_path"), { class: "button" })
        end
        div do
          sub "* Can be changed later."
        end
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :name
      row :email_enabled
      row :mailer
      row :email
      row :push_enabled
      row :push_summary
      row :push_details
      row :sms_enabled
      row :sms_body
      row :created_at
      row :updated_at
    end
  end

  csv do
    column :id
    column :name
    column :email_enabled
    column :mailer
    column :email
    column :push_enabled
    column :push_summary
    column :push_details
    column :sms_enabled
    column :sms_body
    column :created_at
    column :updated_at
  end
end
