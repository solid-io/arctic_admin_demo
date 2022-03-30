# frozen_string_literal: true
class CreatePhones < ActiveRecord::Migration[6.1]
  def change
    create_table :phones do |t|
      t.references :phoneable, polymorphic: true, null: false
      t.string :label
      t.string :phone_number
      t.boolean :is_valid, default: false

      t.timestamps
    end
  end
end
