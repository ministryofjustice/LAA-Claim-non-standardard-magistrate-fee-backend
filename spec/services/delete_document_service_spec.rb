require 'rails_helper'

RSpec.describe DeleteDocumentService do
  before do
    file_path = 'test_path'
    allow(File).to receive(:exist?).and_return(true)

    allow(FileUtils).to receive(:remove).with(file_path).and_return(true)
  end

  context 'when a claim is deleted' do
    let(:claim) { create(:claim, :complete, :as_draft) }

    it 'has no evidence after being deleted' do
      expect(claim.supporting_evidence).not_to eq([])

      described_class.call(claim.id)
      claim.reload

      expect(claim.supporting_evidence).to eq([])
      expect(claim.gdpr_documents_deleted).to be(true)
    end
  end
end
