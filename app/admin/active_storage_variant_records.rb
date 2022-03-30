# frozen_string_literal: true
ActiveAdmin.register ActiveStorageVariantRecord do
  menu label: "Variants", parent: ["Administration", "Active Storage"]

  config.batch_actions = false
  config.remove_action_item(:new)
  actions :index, :show

  index do
    column :id
    column(:blob) { |row| link_to "Blob ##{row.blob_id}", admin_active_storage_blob_path(row.blob_id) }
    column :variation_digest
    # column :preview
    # column(:image) {|row| image_tag(rails_representation_path(row.blob_id ))}
    # column(:image) {|row| {|row|  image_tag(url_for((ActiveStorageAttachment.where(blob_id: v.blob_id).first.record_type.constantize.find 1).logo.variant(resize_to_limit: [60, 60]).processed)) }
    actions
  end

  show do
    attributes_table do
      row :id
      row(:blob) { |row| link_to "Blob ##{row.blob_id}", admin_active_storage_blob_path(row.blob_id) }
      row :variation_digest
      row :preview
      # column(:image) {|row| image_tag(rails_representation_path(row.blob_id ))}
      # column(:image) {|row| {|row|  image_tag(url_for((ActiveStorageAttachment.where(blob_id: v.blob_id).first.record_type.constantize.find 1).logo.variant(resize_to_limit: [60, 60]).processed)) }
    end
  end
end
