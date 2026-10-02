require "csv"

class OpportunitiesCsvExporter
  def initialize(opportunities, title: nil)
    @opportunities = opportunities
    @title = title
  end

  def generate
    CSV.generate(headers: true) do |csv|
      # Add title row if provided
      if @title.present?
        csv << [ @title ]
        csv << [] # Empty row for spacing
      end

      csv << headers

      @opportunities.each do |opportunity|
        csv << [
          opportunity.role_type,
          opportunity.company.name,
          opportunity.company.industry&.full_name,
          opportunity.position_title,
          opportunity.application_date,
          opportunity.status,
          opportunity.salary_range,
          opportunity.chatgpt_match,
          opportunity.jobright_match,
          opportunity.linkedin_match
        ]
      end
    end
  end

  private

  def headers
    [
      "Role Type",
      "Company",
      "Industry",
      "Position Title",
      "Application Date",
      "Status",
      "Salary Range",
      "ChatGPT Match",
      "Jobright Match",
      "LinkedIn Match"
    ]
  end
end
