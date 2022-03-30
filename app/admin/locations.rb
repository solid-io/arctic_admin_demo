# frozen_string_literal: true
ActiveAdmin.register Location do
  menu parent: "Organization"

  permit_params :company_id, :name, :address_1, :address_2, :city, :state, :postal, :country, :time_zone
end
