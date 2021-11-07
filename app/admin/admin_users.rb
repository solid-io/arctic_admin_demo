ActiveAdmin.register AdminUser do
  menu parent: "Administration"

  permit_params :email, :password, :password_confirmation, :time_zone

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
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :email
      row :time_zone
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :time_zone, as: :select,
              collection: ActiveSupport::TimeZone.us_zones.map(&:name)
    end
    f.actions
  end

end
