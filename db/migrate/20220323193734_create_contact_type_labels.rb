# frozen_string_literal: true
class CreateContactTypeLabels < ActiveRecord::Migration[6.1]
  def change
    create_table :contact_type_labels do |t|
      t.string :contact_type
      t.string :label

      t.timestamps
    end
  end
end
