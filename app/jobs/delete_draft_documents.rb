class DeleteDraftDocuments < ApplicationJob
  sidekiq_options retry: 1

  def perform
    return false if filtered_claims.empty?

    filtered_claims.each do |claim|
      claim.with_lock do
        DeleteDocumentService.call(claim.id)
      end
    end
  end

  def filtered_claims
    Claim.where(state: 'draft', updated_at: ..6.months.ago.end_of_day, gdpr_documents_deleted: [false, nil])
  end
end
