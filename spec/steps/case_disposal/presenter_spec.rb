require 'rails_helper'

RSpec.describe Tasks::CaseDisposal, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      plea: plea
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/case_disposal") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::CaseDetails

  describe '#in_progress?' do
    it { expect(subject).not_to be_in_progress }
  end

  describe '#completed?' do
    PleaOptions.values.each do |value|
      context "when plea is set to #{value}" do
        let(:plea) { value }

        context 'when plea_type is set' do
          it { expect(subject).to be_completed }
        end
      end
    end

    context 'when plea is not guilty' do
      let(:plea) { 'not_guilty' }

      it { expect(subject).to be_completed }
    end

    context 'when plea is not set' do
      it { expect(subject).not_to be_completed }
    end
  end
end
