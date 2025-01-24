module Nsm
  class ImportsController < ApplicationController
    include ClaimCreatable

    def new
      @form_object = ImportForm.new
    end

    def create
      @form_object = ImportForm.new(params.expect(nsm_import_form: [:file_upload]))

      if @form_object.valid?
        initialize_application do |claim|
          success_message = ImportService.call(claim, @form_object)

          if success_message
            redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: success_message }
          else
            render :new
          end
        end
      else
        render :new
      end
    end

    def self.model_class
      Claim
    end
  end
end
