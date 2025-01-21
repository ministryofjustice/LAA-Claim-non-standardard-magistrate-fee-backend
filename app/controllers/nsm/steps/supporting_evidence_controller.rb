# frozen_string_literal: true

module Nsm
  module Steps
    class SupportingEvidenceController < Nsm::Steps::BaseController
      include MultiFileUploadable
      before_action :supporting_evidence

      def edit
        @form_object = SupportingEvidenceForm.build(
          current_application
        )
        @supporting_documents = supporting_evidence
      end

      def update
        @supporting_documents = supporting_evidence
        update_and_advance(SupportingEvidenceForm, as: :supporting_evidence)
      end

      def destroy
        evidence = current_application.supporting_evidence.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error('shared.shared_upload_errors.unable_delete', e)
      end

      def download
        render layout: 'printing'
      end

      private

      def supporting_evidence
        current_application.supporting_evidence
      end

      def file_uploader
        @file_uploader ||= FileUpload::FileUploader.new
      end

      def upload_file(params)
        current_application.gdpr_documents_deleted = false
        file_path = file_uploader.upload(params[:documents])
        save_file(params[:documents], file_path)
      end

      def save_file(params, file_path)
        current_application.supporting_evidence.create(
          file_name: params.original_filename,
          file_type: params.content_type,
          file_size: params.tempfile.size,
          file_path: file_path
        )
      end
    end
  end
end
