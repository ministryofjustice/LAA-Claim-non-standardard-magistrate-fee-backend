# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::SubmissionMailer, type: :mailer do
  let(:feedback_template) { 'd07d03fd-65d0-45e4-8d49-d4ee41efad35' }
  let(:application) do
    create(:prior_authority_application, :with_defendant, :with_created_primary_quote, :with_created_alternative_quote,
           :with_ufn)
  end

  describe '#notify' do
    subject(:mail) { described_class.notify(application) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient from config' do
      expect(mail.to).to eq(['provider@example.com'])
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end

    it 'sets personalisation from args' do
      expect(
        mail.govuk_notify_personalisation
      ).to include(
        LAA_case_reference: 'LAA-n4AohV',
        UFN: '120423/001',
        defendant_name: 'bob jim',
        claim_total: '£330.00',
        date: DateTime.now.to_fs(:stamp),
        feedback_url: 'tbc'
      )
    end
  end
end
