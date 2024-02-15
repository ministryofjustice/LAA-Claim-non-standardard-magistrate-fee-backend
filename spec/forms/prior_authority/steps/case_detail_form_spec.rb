require 'rails_helper'

RSpec.describe PriorAuthority::Steps::CaseDetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      **case_detail_attributes
    }
  end

  describe '#validate' do
    let(:application) { instance_double(PriorAuthorityApplication) }

    context 'with case details' do
      let(:case_detail_attributes) do
        {
          main_offence: 'Supply a controlled drug of Class A - Heroin',
          rep_order_date: Date.yesterday,
          defendant_attributes: { 'maat' => '123456' },
          client_detained: true,
          client_detained_prison: 'HMP Bedford',
          subject_to_poca: false,
        }
      end

      it { is_expected.to be_valid }
    end

    context 'with invalid case details' do
      let(:case_detail_attributes) do
        {
          main_offence: nil,
          rep_order_date: nil,
          defendant_attributes: { 'maat' => nil },
          client_detained: nil,
          client_detained_prison: nil,
          subject_to_poca: nil,
        }
      end

      it 'has validation errors' do
        expect(form).not_to be_valid
        expect(form.errors.messages.values.flatten)
          .to include('Enter the main offence',
                      'Date cannot be blank',
                      'Enter the MAAT number',
                      'Select yes if your client is detained',
                      'Select yes if this case is subject to POCA (Proceeds of Crime Act 2002)?')
      end
    end
  end

  describe '#save' do
    subject(:save) { form.save }

    let(:application) { create(:prior_authority_application) }

    context 'with valid case details' do
      let(:case_detail_attributes) do
        {
          main_offence: 'Supply a controlled drug of Class A - Heroin',
          rep_order_date: Date.yesterday,
          defendant_attributes: { 'maat' => '123456' },
          client_detained: true,
          client_detained_prison: 'HMP Bedford',
          subject_to_poca: false,
        }
      end

      it 'persists the case details' do
        expect { save }.to change { application.reload.attributes }
          .from(
            hash_including(
              'main_offence' => nil, 'rep_order_date' => nil,
              'client_detained' => nil, 'client_detained_prison' => nil, 'subject_to_poca' => nil,
            )
          )
          .to(
            hash_including(
              'main_offence' => 'Supply a controlled drug of Class A - Heroin', 'rep_order_date' => Date.yesterday,
              'client_detained' => true, 'client_detained_prison' => 'HMP Bedford', 'subject_to_poca' => false,
            )
          )
      end

      it 'persists the defendant' do
        expect { save }.to change { application.reload.defendant }.from(nil)
        expect(application.defendant).to have_attributes(maat: '123456')
      end
    end

    context 'with incomplete case details' do
      let(:case_detail_attributes) do
        {
          main_offence: nil,
          rep_order_date: nil,
          defendant_attributes: { 'maat' => nil },
          client_detained: nil,
          client_detained_prison: nil,
          subject_to_poca: nil,
        }
      end

      it 'does not persist the case details' do
        expect { save }.not_to change { application.reload.attributes }
          .from(
            hash_including(
              'main_offence' => nil,
              'rep_order_date' => nil,
              'client_detained' => nil,
              'client_detained_prison' => nil,
              'subject_to_poca' => nil,
            )
          )
      end

      it 'does not persist the defendant' do
        expect { save }.not_to change { application.reload.defendant }.from(nil)
      end
    end
  end
end
