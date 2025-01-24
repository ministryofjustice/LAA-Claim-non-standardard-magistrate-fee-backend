require 'rails_helper'

RSpec.describe DeleteDraftDocuments do
  subject { described_class.new }

  before do
    claim&.save
    allow(File).to receive(:exist?).and_return(true)
    allow(FileUtils).to receive(:remove).with('test_path').and_return(true)
  end

  describe '#perform' do
    context 'when the claim is older than 6 months old' do
      let(:claim) { create(:claim, :as_draft, :complete, updated_at: 6.months.ago) }

      it 'updates the db record when 6 months old' do
        expect(subject.filtered_claims).not_to eq([])
        subject.perform

        claim.reload
        expect(claim.supporting_evidence).to eq([])
        expect(claim.gdpr_documents_deleted).to be(true)
      end
    end

    context 'when the claim is not older than 6 months old' do
      let(:claim) { create(:claim, :as_draft, :complete) }

      it 'does not update the record when not 6 months old' do
        expect(DeleteDocumentService).not_to receive(:call)
        expect(subject.filtered_claims).to eq([])

        subject.perform

        claim.reload
        expect(claim.supporting_evidence).not_to eq([])
        expect(claim.gdpr_documents_deleted).to be_nil
      end
    end
  end
end
