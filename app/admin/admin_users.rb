# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  menu parent: "Administration"

  permit_params :email, :password, :password_confirmation, :time_zone, :avatar,
                admin_user_companies_attributes: [:id, :admin_user_id, :company_id, :_destroy],
                admin_user_help_preferences_attributes: [:id, :controller_name, :enabled, :_destroy],
                addresses_attributes: [:id, :label, :address_line_1, :address_line_2, :city, :state, :zip, :default, :_destroy],
                phones_attributes: [:id, :label, :phone_number, :is_valid, :_destroy],
                admin_user_notification_preference_attributes: [:id, :admin_user_id, :email_enabled, :push_enabled, :sms_enabled]

  controller do
    def scoped_collection
      AdminUser.includes(avatar_attachment: :blob)
    end
  end

  action_item :send_email_example, only: :edit do
    link_to("Send Example Email", send("send_email_example_admin_#{controller_name.singularize}_path"), { class: "button" })
  end

  member_action :send_email_example, mehtod: :get do
    ExampleMailer.trust_pilot_invitation(resource).deliver_later
    redirect_to send("edit_admin_#{controller_name.singularize}_path", params[:id]), notice: "Your email has been sent.."
  end

  action_item :send_push, only: :edit  do
    link_to("Send push", send("send_push_admin_#{controller_name.singularize}_path"), { class: "button" })
  end

  member_action :send_push, mehtod: :get  do
    UserNotification.with(user: resource).deliver(resource)
    redirect_to send("edit_admin_#{controller_name.singularize}_path", params[:id]), notice: "Your webpush notification has been sent.."
  end

  member_action :delete_avatar, method: :get do
    resource.avatar.purge
    redirect_to admin_admin_user_path(params[:id]), notice: "Your avatar has been removed."
  end

  filter :id
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :time_zone, as: :select,
        collection: proc { AdminUser.all.pluck(:time_zone).uniq }

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :time_zone
    column("Locked Out") { |user| icon("fas", true ? "lock" : "lock-open") }
    column("Locked In") { |user| icon("fas", false ? "lock" : "lock-open") }
    column("Locked In") { |user| icon("fas", true ? "user" : "lock-open") }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row(:avatar) { |admin_user| admin_user.avatar.attached? ? image_tag(user_avatar(admin_user, 30), style: "border-radius: 50%;") : "" }
      row :email
      row :time_zone
      row :sign_in_count
      list_row(admin_user.companies.present? && admin_user.companies.count > 1 ? "Companies" : "Company") { |admin_user| admin_user.companies.map(&:name) }
      list_row(:locations) { |admin_user| admin_user.locations.map(&:name) }
      row :created_at
      row :updated_at
    end
    if !admin_user.companies.empty?
      table_for admin_user.companies do
        column(:company) { |company| link_to company.name, [ :admin, company ] }
      end
    end
    if !admin_user.locations.empty?
      table_for admin_user.locations do
        column(:location) { |location| link_to location.name, [ :admin, location ] }
        column(:address) { |location| location.address_display }
      end
    end
  end

  form do |f|
    render "form", context: self, f: f
  end
end
