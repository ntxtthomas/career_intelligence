class ExperimentsController < ApplicationController
  def index
    analyzer = ExperimentAnalyzer.new(current_or_demo_user.opportunities.where.not(application_date: nil))

    @conversion_by_channel = analyzer.conversion_by_channel
    @conversion_by_domain_match = analyzer.conversion_by_domain_match
    @conversion_by_fit_map = analyzer.conversion_by_fit_map
    @response_rate_breakdown = analyzer.response_rate_breakdown
  end
end
