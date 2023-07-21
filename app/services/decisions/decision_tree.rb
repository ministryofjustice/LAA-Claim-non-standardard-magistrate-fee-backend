module Decisions
  class DecisionTree < DslDecisionTree
    # used to add custom methods to filter/query the data
    WRAPPER_CLASS = CustomWrapper

    from(:claim_type).goto(show: :start_page)
    # start_page to firm_details is a hard coded link as show page
    from(:firm_details)
      .when(-> { application.defendants.none? })
      .goto(edit: :defendant_details, defendant_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.defendants, Steps::DefendantDetailsForm) })
      .goto(edit: :defendant_details, defendant_id: ->(inst) { inst.id })
      .goto(edit: :defendant_summary)
    from(:defendant_details).goto(edit: :defendant_summary)
    from(:defendant_delete).goto(edit: :defendant_summary)
    from(:defendant_summary)
      .when(-> { add_another.yes? && first_invalid(application.defendants, Steps::DefendantDetailsForm) })
      .goto(edit: :defendant_details, defendant_id: ->(inst) { inst.id })
      .when(-> { add_another.yes? })
      .goto(edit: :defendant_details, defendant_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.defendants, Steps::DefendantDetailsForm) })
      .goto(edit: :defendant_summary)
      .goto(edit: :case_details)
    from(:case_details).goto(edit: :hearing_details)
    from(:hearing_details).goto(edit: :case_disposal)
    from(:case_disposal).goto(edit: :reason_for_claim)
    from(:reason_for_claim).goto(edit: :claim_details)
    from(:claim_details)
      .when(-> { application.work_items.none? })
      .goto(edit: :work_item, work_item_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.work_items, Steps::WorkItemForm) })
      .goto(edit: :work_item, work_item_id: ->(inst) { inst.id })
      .goto(edit: :work_items)
    from(:work_item).goto(edit: :work_items)
    from(:work_item_delete)
      .when(-> { application.work_items.none? })
      .goto(edit: :work_item, work_item_id: StartPage::NEW_RECORD)
      .goto(edit: :work_items)
    from(:work_items)
      .when(-> { add_another.yes? })
      .goto(edit: :work_item, work_item_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.work_items, Steps::WorkItemForm) })
      .goto(edit: :work_items)
      .goto(edit: :letters_calls)
    from(:letters_calls)
      .when(-> { application.disbursements.none? })
      .goto(edit: :disbursement_type, disbursement_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.disbursements, Steps::DisbursementTypeForm) })
      .goto(edit: :disbursement_type, disbursement_id: ->(inst) { inst.id })
      .when(-> { first_invalid(application.disbursements, Steps::DisbursementCostForm) })
      .goto(edit: :disbursement_cost, disbursement_id: ->(inst) { inst.id })
      .goto(edit: :disbursements)
    from(:disbursement_type)
      .goto(edit: :disbursement_cost, disbursement_id: -> { record.id })
    from(:disbursement_cost).goto(edit: :disbursements)
    from(:disbursement_delete)
      .when(-> { application.disbursements.none? })
      .goto(edit: :disbursement_type, disbursement_id: StartPage::NEW_RECORD)
      .goto(edit: :disbursements)
    from(:disbursements)
      .when(-> { add_another.yes? })
      .goto(edit: :disbursement_type, disbursement_id: StartPage::NEW_RECORD)
      .when(-> { first_invalid(application.disbursements, Steps::DisbursementTypeForm, Steps::DisbursementCostForm) })
      .goto(edit: :disbursements)
      .goto(show: :cost_summary)
    # cost_summary to other_info is a hard coded link as show page
    from(:other_info).goto(show: :check_answers)
    # check_answers to equality is a hard coded link as show page
    from(:equality)
      .when(-> { answer_equality.yes? }).goto(edit: :equality_questions)
      .goto(edit: :solicitor_declaration)
    from(:equality_questions).goto(edit: :solicitor_declaration)
    from(:solicitor_declaration).goto(show: :claim_confirmation)
  end
end
