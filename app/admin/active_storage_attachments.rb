ActiveAdmin.register ActiveStorageAttachment do
  menu label: "Attachments", parent: ["Administration", "Active Storage"]

  config.batch_actions = false
  config.remove_action_item(:new)
  actions :index, :show

  # controller do
  #   def scoped_collection
  #     ActiveStorageAttachment.includes(:active_storage_blobs, :active_storage_variant_records)
  #   end
  # end

  index do
    column :id
    column :name
    column(:record_type) {|row| row.name == 'image' ? row.record_type : link_to("#{row.record_type}", public_send("admin_#{(row.record_type.constantize.find row.record_id).to_partial_path.split("/")[1]}_path", row.record_id)  ) }
    column(:blob) { |row| link_to "Blob ##{row.blob_id}", admin_active_storage_blob_path(row.blob_id) }
    list_column(:variants) { |row| ActiveStorageVariantRecord.where(blob_id: row.blob_id).map{ |variant|link_to "Variant ##{variant.id}", admin_active_storage_variant_record_path(ActiveStorageVariantRecord.find(variant.id)) } }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row(:record_type) {|row| row.name == 'image' ? row.record_type : link_to("#{row.record_type}", public_send("admin_#{(row.record_type.constantize.find row.record_id).to_partial_path.split("/")[1]}_path", row.record_id)  ) }
      row(:blob) { |row| link_to "Blob ##{row.blob_id}", admin_active_storage_blob_path(row.blob_id) }
      row(:variants) { |row| link_to "#{row.name == 'image' ? "Variant" : row.record_type} ##{row.record_id}", admin_active_storage_variant_record_path(row.record_id) }
      row :created_at
    end
  end
end