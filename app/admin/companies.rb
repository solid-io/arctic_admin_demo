ActiveAdmin.register Company do
  menu parent: "Organization"

  permit_params :name, :description, :subdomain, :domain

end
