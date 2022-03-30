# frozen_string_literal: true
ActiveAdmin.register ContactTypeLabel do
  menu label: "Contact Type Labels", parent: "Base Setup"

  permit_params :contact_type, :label

  filter :id
  filter :contact_type, as: :select, collection: ContactTypeLabel::CONTACT_TYPE_VALUES
  filter :label
  preserve_default_filters!

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.input :contact_type, as: :select, collection: ContactTypeLabel::CONTACT_TYPE_VALUES
    f.input :label
    actions
  end

  index do
    selectable_column
    id_column
    column(:contact_type) { |contact_type| contact_type.contact_type.humanize }
    column :label
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :id
      row(:contact_type) { |contact_type| contact_type.contact_type.humanize }
      row :label
      row :created_at
      row :updated_at
    end
  end

  csv do
    column :id
    column(:contact_type) { |contact_type| contact_type.contact_type.humanize }
    column :label
    column :created_at
    column :updated_at
  end
end
