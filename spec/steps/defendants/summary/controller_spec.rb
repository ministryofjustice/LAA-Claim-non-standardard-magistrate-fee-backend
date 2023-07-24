require 'rails_helper'

RSpec.describe Steps::DefendantSummaryController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
