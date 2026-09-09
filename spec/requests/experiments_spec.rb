require "rails_helper"

RSpec.describe "Experiments", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let!(:company) { Company.create!(name: "Experiments Co", industry: "Technology", company_type: "Product", user: user) }

  let!(:opportunity) do
    Opportunity.create!(
      company: company,
      position_title: "Backend Engineer",
      role_type: "software_engineer",
      application_date: Date.current,
      acquisition_channel: "referral",
      domain_match: "direct",
      fit_map_used: true,
      response_type: "human"
    )
  end

  describe "GET /experiments" do
    it "returns 200 and exposes the four metrics" do
      get experiments_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Conversion by Acquisition Channel")
      expect(response.body).to include("Conversion by Domain Match")
      expect(response.body).to include("Conversion by Fit Map Usage")
      expect(response.body).to include("Response Rate Breakdown")
      expect(response.body).to include("Referral")
    end

    it "excludes opportunities with no application_date from all four panels" do
      Opportunity.create!(
        company: company,
        position_title: "Not Yet Submitted Role",
        role_type: "software_engineer",
        application_date: nil,
        acquisition_channel: "network",
        domain_match: "adjacent",
        fit_map_used: false,
        response_type: "automated"
      )

      get experiments_path

      expect(response).to have_http_status(:ok)
      # Values unique to the unsubmitted opportunity should not surface in any panel.
      expect(response.body).not_to include("Network")
      expect(response.body).not_to include("Adjacent")
      expect(response.body).not_to include("No fit map")
      expect(response.body).not_to include("Automated")
    end
  end
end
