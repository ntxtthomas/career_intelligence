require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let!(:company) do
    Company.create!(
      name: "Metrics Co",
      industry: create(:industry, name: "Technology"),
      location: "Remote",
      website: "https://metrics.example",
      company_type: "Product",
      user: user
    )
  end

  describe "GET /dashboard" do
    it "counts one interview process per submitted application and calculates conversion correctly" do
      submitted_with_many_rounds = Opportunity.create!(
        company: company,
        position_title: "Platform Engineer",
        role_type: "software_engineer",
        status: "interviewing",
        application_date: Date.current - 3.days
      )

      submitted_with_one_round = Opportunity.create!(
        company: company,
        position_title: "Senior Backend Engineer",
        role_type: "software_engineer",
        status: "interviewing",
        application_date: Date.current - 2.days
      )

      submitted_without_interviews = Opportunity.create!(
        company: company,
        position_title: "Ruby Engineer",
        role_type: "software_engineer",
        status: "applied",
        application_date: Date.current - 1.day
      )

      not_submitted_with_interviews = Opportunity.create!(
        company: company,
        position_title: "Staff Engineer",
        role_type: "software_engineer",
        status: "assessed"
      )

      %w[recruiter technical final].each do |stage|
        InterviewSession.create!(
          opportunity: submitted_with_many_rounds,
          stage: stage,
          scheduled_at: Time.current,
          format: "video",
          status: "completed"
        )
      end

      InterviewSession.create!(
        opportunity: submitted_with_one_round,
        stage: "recruiter",
        scheduled_at: Time.current,
        format: "phone",
        status: "completed"
      )

      InterviewSession.create!(
        opportunity: not_submitted_with_interviews,
        stage: "recruiter",
        scheduled_at: Time.current,
        format: "phone",
        status: "completed"
      )

      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Companies That Interviewed Me")
      expect(response.body).to match(/Companies That Interviewed Me.*?<div class=\"card-number\">2<\/div>/m)
      expect(response.body).to include("66.7% of applications submitted")
    end

    it "renders the tech skills widget when skills are sparse across opportunities" do
      7.times do |index|
        opportunity = Opportunity.create!(
          company: company,
          position_title: "Distinct Tech Role #{index}",
          role_type: "software_engineer"
        )
        technology = Technology.create!(name: "Distinct Tech #{index}", category: "Backend")
        OpportunityTechnology.create!(opportunity: opportunity, technology: technology)
      end

      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Top 4 Tech Skills to Focus On")
    end

    it "rolls industry segments up into their top-level industry in the industry charts" do
      edtech = create(:industry, name: "EdTech")
      segment = create(:segment, name: "Family Engagement", parent: edtech)
      segment_company = Company.create!(name: "Segment Co", company_type: "Product", user: user, industry: segment)
      Opportunity.create!(company: segment_company, position_title: "Segment Role", role_type: "software_engineer", application_date: Date.current)

      get dashboard_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<strong>EdTech</strong>: 1")
      expect(response.body).not_to include("Family Engagement")
    end
  end
end
