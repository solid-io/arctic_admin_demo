ActiveAdmin.register AdminUser do
  menu parent: "Administration"

  permit_params :email, :password, :password_confirmation, :time_zone, :avatar

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
    column :created_at
    actions
  end

  show do
    attributes_table do
      row(:avatar) { |admin_user| admin_user.avatar.attached? ? image_tag(user_avatar(admin_user, 30), style: "border-radius: 50%;") : ""}
      row :email
      row :time_zone
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :avatar, as: :attachment,
              input_html: { accept: 'image/png,image/gif,image/jpeg' },
              hint: 'Maximum size of 3MB. JPG, GIF, PNG.',
              image: f.object.avatar.attached? ? url_for(f.object.avatar.variant(resize_to_limit: [60, 60]).processed) : ""
      if admin_user.avatar.attached?
        div style: "margin-left: 430px; margin-bottom: 10px;" do
          link_to "Remove Avatar", delete_avatar_admin_admin_user_path
        end
      end
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :time_zone, as: :select,
              collection: ActiveSupport::TimeZone.us_zones.map(&:name)
    end
    f.actions
  end

end
