module Nsm
  class AssessmentSyncer
    def self.call(claim, record:)
      new(claim, record:).call
    end

    attr_reader :claim, :app_store_record

    def initialize(claim, record:)
      @claim = claim
      @app_store_record = record
    end

    def call
      Rails.logger.debug claim.status
      case claim.status
      when 'submitted', 'granted'
        return
      when 'part_grant'
        sync_overall_comment
        sync_letter_adjustments
      when 'provider_requested', 'further_info'
        sync_overall_comment
      end
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for claim '#{claim.id}'")
    end

    private

    def sync_overall_comment
      event_type = claim.provider_requested? || claim.further_info? ? 'send_back' : 'decision'
      comment_event = app_store_record['events'].select { _1['event_type'] == event_type }
                                                .max_by { DateTime.parse(_1['created_at']) }
      claim.update(assessment_comment: comment_event.dig('details', 'comment'))
    end

    def sync_letter_adjustments
      claim.update(allowed_letters: letters['count']) if letters['count_original'].present?
      claim.update(allowed_letters_uplift: letters['uplift']) if letters['uplift_original'].present?
      claim.update(letters_adjustment_comment: letters['adjustment_comment']) if letters['adjustment_comment'].present?
    end

    def letters
      app_store_record['application']['letters_and_calls'].select { _1['type']['value'] == 'letters'}
    end
  end
end
