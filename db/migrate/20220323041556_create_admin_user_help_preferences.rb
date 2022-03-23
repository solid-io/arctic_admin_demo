class CreateAdminUserHelpPreferences < ActiveRecord::Migration[6.1]
  def change
    create_table :admin_user_help_preferences do |t|
      t.belongs_to :admin_user, null: false, foreign_key: true
      t.string :controller_name, null: false
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
