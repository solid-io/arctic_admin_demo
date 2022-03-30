ActiveAdmin.register Company do
  menu parent: "Organization"

  permit_params :name, :description, :subdomain, :domain, :logo,
                locations_attributes: [:id, :company_id, :name, :address_1, :address_2, :city, :state, :postal, :country, :time_zone, :_destroy]

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
    bool_column("Has Location?") { |admin_user| admin_user.has_locations? }
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
    table_for company.locations do
      column(:location) { |location| link_to location.name, [ :admin, location ] }
      column(:address) { |location| location.address_display }
    end
  end

  form do |f|
    tabs do
      tab "Details" do
        f.inputs do
          f.input :logo, as: :attachment,
                  input_html: { accept: "image/png,image/gif,image/jpeg" },
                  hint: "Maximum size of 3MB. JPG, GIF, PNG.",
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
      end
      tab "Locations" do
        f.inputs do
          f.has_many :locations, heading: false, allow_destroy: true do |l|
            if !l.object.new_record?
              l.input :id, input_html: { disabled: true }
            end
            l.input :company_id, selected: f.object.id, as: :hidden
            l.input :name
            l.input :address_1
            l.input :address_2
            l.input :city
            l.input :state
            l.input :postal
            l.input :country
            l.input :time_zone
          end
        end
      end
    end
    f.actions
  end
end
