RSpec.shared_examples 'a generic decision' do |step_name, controller_name, form_class = nil, action_name: :edit|
  let(:local_form) { form_class&.new(application:) || form }
  let(:decision_tree) { described_class.new(local_form, as: step_name) }

  context "when step is #{step_name}" do
    it "moves to #{controller_name}##{action_name}" do
      expect(decision_tree.destination).to eq(
        action: action_name,
        controller: controller_name,
        id: application,
      )
    end
  end
end

RSpec.shared_examples 'an add_another decision' do |step_name, yes_controller_name, no_controller_name, id_field, action_name: :edit, block: nil|
  let(:form) { Steps::AddAnotherForm.new(application:, add_another:) }
  let(:decision_tree) { described_class.new(form, as: step_name) }
  let(:add_another) { 'yes' }

  context "when step is #{step_name}" do
    context 'when add_another is YES' do
      it "moves to #{yes_controller_name}##{action_name}" do
        expect(decision_tree.destination).to match(
          action: action_name,
          controller: yes_controller_name,
          id: application,
          id_field => an_instance_of(String),
        )
      end

      context 'additional tests', &(block || action_or_block)
    end

    context 'when add_another is NO' do
      let(:add_another) { 'no' }

      it "moves to #{no_controller_name}##{action_name}" do
        expect(decision_tree.destination).to eq(
          action: action_name,
          controller: no_controller_name,
          id: application,
        )
      end
    end
  end
end