module PriorAuthority
  module Steps
    class AuthorityValueController < BaseController
      before_action :set_authority_threshold

      def edit
        @form_object = AuthorityValueForm.build(
          current_application
        )
      end

      def update
        @form_object = AuthorityValueForm.build(current_application)
        @form_object.assign_attributes(allowed_params)

        if @form_object.valid?
          if @form_object.authority_value
            redirect_to offboard_prior_authority_application_path(current_application)
          else
            update_and_advance(AuthorityValueForm, as:, after_commit_redirect_path:)
          end
        else
          render :edit
        end
      end

      def allowed_params
        params.expect(prior_authority_steps_authority_value_form: [:authority_value])
      end

      private

      def as
        :authority_value
      end

      def set_authority_threshold
        @authority_threshold = current_application.prison_law? ? 500 : 100
      end
    end
  end
end
