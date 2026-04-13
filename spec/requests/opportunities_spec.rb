require "rails_helper"

RSpec.describe "Opportunities", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let!(:company) do
    Company.create!(
      name: "FilterCo",
      industry: "Technology",
      location: "Remote",
      website: "https://filterco.example",
      company_type: "Product",
      user: user
    )
  end

  let!(:applied_opportunity) do
    Opportunity.create!(
      company: company,
      position_title: "Applied Role",
      role_type: "software_engineer",
      status: "applied",
      application_date: Date.current
    )
  end

  let!(:interviewing_opportunity) do
    Opportunity.create!(
      company: company,
      position_title: "Interviewing Role",
      role_type: "software_engineer",
      status: "interviewing",
      application_date: Date.current
    )
  end

  let!(:closed_opportunity) do
    Opportunity.create!(
      company: company,
      position_title: "Closed Role",
      role_type: "software_engineer",
      status: "closed",
      application_date: Date.current
    )
  end

  describe "GET /opportunities" do
    it "renders status filter options" do
      get opportunities_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("")
      expect(response.body).to include("Applied")
      expect(response.body).to include("Interviewing")
      expect(response.body).to include("Closed")
    end

    it "filters opportunities by applied status" do
      get opportunities_path, params: { status: "applied" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Applied Role")
      expect(response.body).not_to include("Interviewing Role")
      expect(response.body).not_to include("Closed Role")
    end

    it "filters opportunities by interviewing status" do
      get opportunities_path, params: { status: "interviewing" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Interviewing Role")
      expect(response.body).not_to include("Applied Role")
      expect(response.body).not_to include("Closed Role")
    end

    it "filters opportunities by closed status" do
      get opportunities_path, params: { status: "closed" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Closed Role")
      expect(response.body).not_to include("Applied Role")
      expect(response.body).not_to include("Interviewing Role")
    end
  end
end
