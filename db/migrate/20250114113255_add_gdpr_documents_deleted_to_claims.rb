class AddGdprDocumentsDeletedToClaims < ActiveRecord::Migration[8.0]
  def change
    add_column :claims, :gdpr_documents_deleted, :boolean, default: false
  end
end
