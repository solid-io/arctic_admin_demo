ActiveAdmin.register AdminUser do
  menu parent: "Administration"

  permit_params :email, :password, :password_confirmation, :time_zone, :avatar,
                admin_user_companies_attributes: [:id, :admin_user_id, :company_id, :_destroy]

  controller do
    def scoped_collection
      AdminUser.includes(avatar_attachment: :blob)
    end
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
      row(:avatar) { |admin_user| admin_user.avatar.attached? ? image_tag(user_avatar(admin_user, 30), style: "border-radius: 50%;") : ""}
      row :email
      row :time_zone
      row :sign_in_count
      list_row(admin_user.companies.present? && admin_user.companies.count > 1 ? "Companies" : "Company") {|admin_user| admin_user.companies.map(&:name)}
      list_row(:locations) {|admin_user| admin_user.locations.map(&:name) }
      row :created_at
      row :updated_at

    end
    table_for admin_user.companies do
      column(:company) {|company| link_to company.name, [ :admin, company ]}
    end
    table_for admin_user.locations do
      column(:location) {|location| link_to location.name, [ :admin, location ]}
      column(:address) {|location| location.address_display }
    end
  end

  form do |f|
    tabs do
      tab 'Details'do
        f.inputs do
          f.input :avatar, as: :attachment,
                  input_html: { accept: 'image/png,image/gif,image/jpeg' },
                  hint: 'Maximum size of 3MB. JPG, GIF, PNG.',
                  image: f.object.avatar.attached? ? url_for(f.object.avatar.variant(resize_to_limit: [60, 60]).processed) : ""
          if admin_user.avatar.attached?
            div style: "margin-left: 430px; margin-bottom: 10px;" do
              span do
                icon("fas", "user")
              end
              span do
                link_to "Remove Avatar", delete_avatar_admin_admin_user_path
              end
            end
          end
          f.input :email
          f.input :password
          f.input :password_confirmation
          f.input :time_zone, as: :select,
                  collection: ActiveSupport::TimeZone.us_zones.map(&:name)
        end
      end
      tab 'Companies' do
        f.inputs do
          f.has_many :admin_user_companies, heading: false, allow_destroy: true do |c|
            c.input :company_id, as: :select,
                    collection: Company.all
          end
        end
      end
    end
    f.actions
  end

end
