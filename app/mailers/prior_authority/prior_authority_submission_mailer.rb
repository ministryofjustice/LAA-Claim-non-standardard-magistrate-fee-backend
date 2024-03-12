# frozen_string_literal: true

module PriorAuthority
  class PriorAuthoritySubmissionMailer < GovukNotifyRails::Mailer
    def notify(application)
      @application = application
      set_template('d07d03fd-65d0-45e4-8d49-d4ee41efad35')
      set_personalisation(
        LAA_case_reference: case_reference,
        UFN: unique_file_number,
        defendant_name: defendant_name,
        claim_total: application_total,
        date: submission_date,
        feedback_url: feedback_url
      )
      mail(to: email_recipient)
    end

    private

    def email_recipient

    end

    def case_reference
      @application.laa_reference
    end

    def unique_file_number
      @application.ufn
    end

    def defendant_name
      "#{@application.defendant.first_name} #{@application.defendant.last_name}"
    end

    def application_total

    end

    def submission_date
      DateTime.now.to_fs(:stamp)
    end

    def feedback_url
      Rails.configuration.x.contact.feedback_url
    end
  end
end
