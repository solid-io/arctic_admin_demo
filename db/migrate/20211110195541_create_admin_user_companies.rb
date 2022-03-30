# frozen_string_literal: true
class CreateAdminUserCompanies < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_user_companies do |t|
      t.belongs_to :admin_user, null: false, foreign_key: true
      t.belongs_to :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
