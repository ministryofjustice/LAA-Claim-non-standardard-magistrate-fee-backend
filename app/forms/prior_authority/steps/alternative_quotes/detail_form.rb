module PriorAuthority
  module Steps
    module AlternativeQuotes
      class DetailForm < PriorAuthority::Steps::QuoteCostForm
        include Rails.application.routes.url_helpers

        def self.attribute_names
          super - %w[file_upload]
        end

        attribute :id, :string
        attribute :contact_first_name, :string
        attribute :contact_last_name, :string
        attribute :organisation, :string
        attribute :postcode, :string
        attribute :travel_time, :time_period
        attribute :travel_cost_per_hour, :gbp
        attribute :additional_cost_list, :string
        attribute :additional_cost_total, :gbp

        validates :contact_first_name, presence: true
        validates :contact_last_name, presence: true
        validates :organisation, presence: true
        validates :postcode, presence: true, uk_postcode: { allow_partial: true }
        include DocumentUploadable
        include QuoteCostValidations

        validates :travel_time, time_period: true, presence: { if: -> { travel_cost_per_hour.to_i.positive? } }
        validates :travel_cost_per_hour,
                  is_a_number: true,
                  presence: { if: -> { travel_time.is_a?(IntegerTimePeriod) && travel_time.to_i.positive? } }

        validates :additional_cost_list, presence: { if: -> { additional_cost_total.to_i.positive? } }
        validates :additional_cost_total, is_a_number: true, presence: { if: -> { additional_cost_list.present? } }

        def total_cost
          main_cost + travel_cost + additional_cost
        end

        def http_verb
          record.persisted? ? :patch : :post
        end

        def url
          if record.persisted?
            prior_authority_steps_alternative_quote_detail_path(application, record)
          else
            prior_authority_steps_alternative_quote_details_path(application)
          end
        end

        def main_cost
          per_item? ? item_cost : time_cost
        end

        def travel_cost
          return 0 if travel_time.is_a?(Hash)
          return 0 if travel_cost_per_hour.is_a?(String)
          return 0 unless travel_cost_per_hour.to_i.positive? && travel_time.to_i.positive?

          (travel_cost_per_hour * (travel_time.hours + (travel_time.minutes / 60.0))).round(2)
        end

        def additional_cost
          additional_cost_total.to_f
        end

        def document
          record.document || record.build_document
        end

        delegate :contact_full_name, to: :record

        def variable_cost_type?
          false
        end

        def cost_type
          @cost_type ||= ServiceCostForm.build(
            application.primary_quote,
            application:
          ).cost_type
        end

        private

        def persist!
          return false unless save_file

          record.update!(attributes.except('id', 'service_type', 'file_upload').merge(reset_attributes))
        end

        def file_is_optional?
          true
        end
      end
    end
  end
end
