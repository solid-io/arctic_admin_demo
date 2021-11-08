ActiveAdmin.register Company do
  menu parent: "Organization"

  permit_params :name, :description, :subdomain, :domain, :logo

  member_action :delete_logo, method: :get do
    resource.logo.purge
    redirect_to admin_company_path(params[:id]), notice: "Your logo has been removed."
  end

  filter :id
  filter :name
  filter :description
  filter :subdomain
  filter :domain
  filter :created_at

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :subdomain
    column :domain
    column :created_at
    actions
  end

  show do
    attributes_table do
      row(:logo) { |company| company.logo.attached? ? image_tag(url_for(company.logo.variant(resize_to_limit: [60, 60]).processed), style: "border-radius: 50%;") : "" }
      row :name
      row :description
      row :subdomain
      row :domain
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :logo, as: :attachment,
              input_html: { accept: 'image/png,image/gif,image/jpeg' },
              hint: 'Maximum size of 3MB. JPG, GIF, PNG.',
              image: f.object.logo.attached? ? url_for(f.object.logo.variant(resize_to_limit: [60, 60]).processed) : ""
      if resource.logo.attached?
        div style: "margin-left: 430px; margin-bottom: 10px;" do
          link_to "Remove Logo", delete_logo_admin_company_path
        end
      end
      f.input :name
      f.input :description
      f.input :subdomain
      f.input :domain
    end
    f.actions
  end

end
