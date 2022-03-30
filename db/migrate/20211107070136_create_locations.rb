# frozen_string_literal: true
class CreateLocations < ActiveRecord::Migration[6.1]
  def change
    create_table :locations do |t|
      t.belongs_to :company, null: false, foreign_key: true
      t.string :name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postal
      t.string :country
      t.string :time_zone

      t.timestamps
    end
  end
end
