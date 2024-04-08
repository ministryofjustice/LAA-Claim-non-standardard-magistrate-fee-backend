module TagHelper
  TAG_COLOURS = {
    submitted: 'govuk-tag--green',
    granted: 'govuk-tag--green',
    auto_grant: 'govuk-tag--green',
    part_grant: 'govuk-tag--blue',
    rejected: 'govuk-tag--red',
    expired: 'govuk-tag--red',
    sent_back: 'govuk-tag--yellow',
    provider_updated: 'govuk-tag--green',
  }.freeze

  def prior_authority_tag_colour(status)
    TAG_COLOURS[status.to_sym]
  end
end
