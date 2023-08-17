module CheckAnswers
  class Report
    include GovukLinkHelper
    include ActionView::Helpers::UrlHelper
    GROUPS = %w[
      about_you
      about_defendant
      about_case
      about_claim
      supporting_evidence
    ].freeze

    attr_reader :claim

    def initialize(claim)
      @claim = claim
    end

    def section_groups
      GROUPS.map do |group_name|
        section_group(group_name, public_send("#{group_name}_section"))
      end
    end

    def as_json(*)
      GROUPS.each_with_object({}) do |group_name, hash|
        group_data = public_send("#{group_name}_section")
        hash[group_name] = group_data.each_with_object({}) do |section, group_hash|
          group_hash[section.section] = section.as_json
        end
      end
    end

    def section_group(name, section_list)
      {
        heading: group_heading(name),
        sections: sections(section_list)
      }
    end

    def sections(section_list)
      section_list.map do |data|
        {
          card: {
            title: data.title,
            actions: actions(data.section)
          },
          rows: data.rows
        }
      end
    end

    def about_you_section
      [YourDetailsCard.new(claim)]
    end

    def about_defendant_section
      [DefendantCard.new(claim)]
    end

    def about_case_section
      [
        CaseDetailsCard.new(claim),
        HearingDetailsCard.new(claim),
        CaseDisposalCard.new(claim)
      ]
    end

    def about_claim_section
      [
        ClaimJustificationCard.new(claim),
        ClaimDetailsCard.new(claim),
        WorkItemsCard.new(claim),
        LettersCallsCard.new(claim),
        DisbursementCostsCard.new(claim),
        OtherInfoCard.new(claim)
      ]
    end

    def supporting_evidence_section
      [
        EvidenceUploadsCard.new(claim)
      ]
    end

    private

    def actions(key)
      helper = Rails.application.routes.url_helpers
      [
        govuk_link_to(
          'Change',
          helper.url_for(controller: "steps/#{key}", action: :edit, id: claim.id, only_path: true)
        ),
      ]
    end

    def group_heading(group_key, **)
      I18n.t("steps.check_answers.groups.#{group_key}.heading", **)
    end
  end
end
