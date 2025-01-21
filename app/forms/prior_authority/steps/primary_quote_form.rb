module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      def self.attribute_names
        super - %w[service_type custom_service_name file_upload]
      end
      attribute :contact_first_name, :string
      attribute :contact_last_name, :string
      attribute :organisation, :string
      attribute :town, :string
      attribute :postcode, :string

      validates :service_type_autocomplete, presence: true
      validates :contact_first_name, presence: true
      validates :contact_last_name, presence: true
      validates :organisation, presence: true
      validates :town, presence: true
      validates :postcode, presence: true, uk_postcode: { allow_partial: true }
      include DocumentUploadable # Include this here so that validations appear in the correct order

      # Using local variable for service_type_autocomplete to avoid issues with
      # assignment of value into two fields service_type and custom_service_name
      attr_accessor :service_type, :custom_service_name, :local_values

      def service_type_autocomplete
        scope = local_values ? self : application
        if scope.service_type == 'custom'
          scope.custom_service_name
        elsif scope.service_type.present?
          scope.service_type
        end
      end

      def service_type_translation
        if application.service_type == 'custom'
          application.custom_service_name
        elsif application.service_type.present?
          QuoteServices.new(application.service_type).translated
        end
      end

      # this should only be used when JS is disabled - otherwise overwritten by service_type_autocomplete_suggestion
      def service_type_autocomplete=(value)
        # ensure that if the suggestion is set first it cannot be overwritten
        return if local_values

        # used to ensure we use the right scope in validations
        self.local_values = true

        self.service_type = value
        self.custom_service_name = nil
      end

      def service_type_autocomplete_suggestion=(value)
        # used to ensure we use the right scope in validations
        self.local_values = true

        if value.in?(translations.keys)
          self.service_type = translations[value]
          self.custom_service_name = nil
        else
          self.service_type = value.present? ? 'custom' : nil
          self.custom_service_name = value
        end
      end

      def document
        record.document || record.build_document
      end

      def draft?
        application.state.in?(%w[pre_draft draft])
      end

      delegate :contact_full_name, to: :record

      private

      def persist!
        return false unless save_file

        save_quote
        reset_quote_cost_fields
        application.update(service_type:, custom_service_name:) if service_type

        # If a change to service type has rendered any alternative quotes invalid,
        # delete them because we don't yet have a UI for highlighting invalidities
        # from the overview screen
        application.alternative_quotes
                   .reject { AlternativeQuotes::DetailForm.build(_1, application:).valid? }
                   .each(&:destroy)
      end

      def default_attributes
        {
          'primary' => true
        }
      end

      def translations
        QuoteServices.values.to_h { [_1.translated, _1.value] }
      end

      def save_quote
        record.update!(attributes.except('service_type', 'custom_service_name', 'file_upload')
                                 .merge(default_attributes))
      end

      def reset_quote_cost_fields
        return unless service_type_rules_changed?

        application.gdpr_documents_deleted = false
        application.quotes.find_each do |quote|
          quote.update!(
            items: nil,
            cost_per_item: nil,
            period: nil,
            cost_per_hour: nil,
            user_chosen_cost_type: nil
          )
        end
      end

      def service_type_rules_changed?
        # If we have changed cost type, e.g. from per_item to per_hour, or we have changed item type,
        # e.g. from pages to words, then values previously entered shouldn't carry across
        service_type_changed? &&
          (current_service_rule.cost_type != previous_service_rule.cost_type ||
           current_service_rule.item != previous_service_rule.item)
      end

      def previous_service_rule
        @previous_service_rule ||= ServiceTypeRule.build(QuoteServices.new(application.service_type))
      end

      def current_service_rule
        @current_service_rule ||= ServiceTypeRule.build(QuoteServices.new(service_type))
      end

      def service_type_changed?
        service_type && application.service_type && service_type != application.service_type
      end
    end
  end
end
