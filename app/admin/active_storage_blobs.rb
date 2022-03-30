# frozen_string_literal: true

ActiveAdmin.register ActiveStorageBlob do
  menu label: "Blobs", parent: ["Administration", "Active Storage"]

  config.batch_actions = false
  config.remove_action_item(:new)
  actions :index, :show

  index do
    column :id
    column :key
    column :filename
    column :content_type
    column :metadata
    column :service_name
    column :byte_size
    column :checksum
    column(:attachments) { |row| link_to "Attachment ##{ActiveStorageAttachment.find_by_blob_id(row.id).id}", admin_active_storage_attachment_path(ActiveStorageAttachment.find_by_blob_id(row.id).id) }
    list_column(:variants) { |row| ActiveStorageVariantRecord.where(blob_id: row.id).map { |variant|link_to "Variant ##{variant.id}", admin_active_storage_variant_record_path(ActiveStorageVariantRecord.find(variant.id)) } }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :key
      row :filename
      row :content_type
      row :metadata
      row :service_name
      row :byte_size
      row :checksum
      row(:attachments) { |row| link_to "Attachment ##{ActiveStorageAttachment.find_by_blob_id(row.id).id}", admin_active_storage_attachment_path(ActiveStorageAttachment.find_by_blob_id(row.id).id) }
      list_row(:variants) { |row| ActiveStorageVariantRecord.where(blob_id: row.id).map { |variant|link_to "Variant ##{variant.id}", admin_active_storage_variant_record_path(ActiveStorageVariantRecord.find(variant.id)) } }
      row :created_at
    end
  end
end
