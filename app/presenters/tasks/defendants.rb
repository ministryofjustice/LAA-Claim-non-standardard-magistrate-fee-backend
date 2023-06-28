module Tasks
  class Defendants < Generic
    PREVIOUS_TASK = FirmDetails
    FORM = Steps::DefendantDetailsForm

    def path
      scope = application.defendants
      count = application.defendants.count

      if count > 1
        edit_steps_defendant_summary_path(application)
      else
        defendant = count.zero? ? scope.create : scope.first
        edit_steps_defendant_details_path(id: application.id, defendant_id: defendant.id)
      end
    end

    def in_progress?
      [
        edit_steps_defendant_summary_path(application),
        edit_steps_defendant_details_path(id: application.id, defendant_id: '')
      ].any? do |path|
        application.navigation_stack.any? { |stack| stack.start_with?(path) }
      end
    end

    def completed?
      application.defendants.any? && application.defendants.all? do |record|
        super(record)
      end
    end
  end
end
