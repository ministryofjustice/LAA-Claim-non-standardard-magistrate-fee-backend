module PriorAuthority
  module Steps
    class NextHearingForm < ::Steps::BaseFormObject
      attribute :next_hearing, :boolean
      attribute :next_hearing_date, :multiparam_date

      validates :next_hearing, inclusion: { in: [true, false] }
      validates :next_hearing_date,
                presence: true,
                multiparam_date: { allow_past: true, allow_future: true },
                if: :next_hearing

      private

      def persist!
        application.update!(attributes_to_reset)
      end

      def attributes_to_reset
        attributes.merge(reset_attributes)
      end

      def reset_attributes
        {
          next_hearing_date: next_hearing ? next_hearing_date : nil,
        }
      end
    end
  end
end
