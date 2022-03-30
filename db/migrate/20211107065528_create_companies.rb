# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :description
      t.string :subdomain
      t.string :domain

      t.timestamps
    end
  end
end
