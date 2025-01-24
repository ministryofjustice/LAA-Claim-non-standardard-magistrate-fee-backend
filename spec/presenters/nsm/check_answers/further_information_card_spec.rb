# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::FurtherInformationCard do
  subject(:card) { described_class.new(further_information, claim) }

  let(:further_information) do
    instance_double(FurtherInformation, information_requested: 'Requested info',
                              information_supplied: 'Supplied info',
                              supporting_documents: supporting_documents,
                              requested_at: Time.zone.now)
  end
  let(:claim) { instance_double(Claim) }

  before do
    allow(Rails.application.routes).to receive(:default_url_options).and_return(host: 'test.host')
  end

  describe '#title' do
    let(:supporting_documents) { [] }

    it 'shows correct title' do
      expect(card.title).to eq("Further information request #{Time.zone.now.strftime('%d %B %Y')}")
    end
  end

  describe '#row_data' do
    context 'with supporting documents' do
      let(:first_doc) { build(:supporting_document, id: 1, file_name: 'further_info1.pdf') }
      let(:second_doc) { build(:supporting_document, id: 2, file_name: 'further_info2.pdf') }
      let(:supporting_documents) do
        [first_doc, second_doc]
      end

      it 'generates expected rows' do
        allow(card).to receive(:url_helper).and_return(double(download_path: '/path/to/download'))
        expect(card.row_data).to eq(
          [
            {
              head_key: 'information_request',
              text: '<p>Requested info</p>',
            },
            {
              head_key: 'your_response',
              text: '<p>Supplied info</p><br><a class="govuk-link" href="/path/to/download">further_info1.pdf</a><br><a class="govuk-link" href="/path/to/download">further_info2.pdf</a>', # rubocop:disable Layout/LineLength
            },
          ]
        )
      end
    end
  end

  describe '#supporting_documents' do
    context 'when gdpr documents are deleted' do
      let(:supporting_documents) { [] }

      before do
        allow(claim).to receive(:is_a?).with(AppStore::V1::Nsm::Claim).and_return(true)
        allow(claim).to receive(:gdpr_documents_deleted?).and_return(true)
      end

      it 'renders the gdpr deleted partial' do
        expect(card.send(:supporting_documents)).to include('Uploaded files deleted. Your uploads are deleted after 6 months to keep your data safe.') # rubocop:disable Layout/LineLength
      end
    end
  end
end
