module PriorAuthority
  class ApplicationsController < ApplicationController
    before_action :authenticate_provider!
    before_action :load_drafts, only: %i[index draft]
    before_action :load_assessed, only: %i[index assessed]
    before_action :load_submitted, only: %i[index submitted]
    layout 'prior_authority'

    def index
      @empty = PriorAuthorityApplication.for(current_provider).none?
    end

    def create
      initialize_application do |paa|
        redirect_to edit_prior_authority_steps_prison_law_path(paa)
      end
    end

    def confirm_delete
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
    end

    def destroy
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
      @model.destroy
      redirect_to prior_authority_applications_path(anchor: 'drafts')
    end

    def draft
      render layout: nil
    end

    def assessed
      render layout: nil
    end

    def submitted
      render layout: nil
    end

    def offboard
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
    end

    private

    def load_drafts
      @draft_pagy, @draft_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).draft)
    end

    def load_assessed
      @assessed_pagy, @assessed_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).assessed)
    end

    def load_submitted
      @submitted_pagy, @submitted_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).submitted)
    end

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_office_code
      current_provider.prior_authority_applications.create!(attributes).tap(&block)
    end

    def service
      Providers::Gatekeeper::PAA
    end

    ORDERS = {
      'ufn' => 'ufn ?',
      'client' => 'defendants.first_name ?, defendants.last_name ?',
      'last_updated' => 'updated_at ?',
      'laa_reference' => 'laa_reference ?',
      'status' => 'status ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    def order_and_paginate(query)
      order_template = ORDERS.fetch(params[:sort_by], 'updated_at ?')
      direction = DIRECTIONS.fetch(params[:sort_direction], 'DESC')
      pagy(query.includes(:defendant).order(order_template.gsub('?', direction)))
    end
  end
end
