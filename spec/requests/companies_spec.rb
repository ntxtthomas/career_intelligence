require "rails_helper"

RSpec.describe "Companies", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let(:edtech) { create(:industry, name: "EdTech") }
  let(:family_engagement) { create(:segment, name: "Family Engagement", parent: edtech) }
  let(:k12) { create(:segment, name: "K-12", parent: edtech) }

  let!(:root_company) { Company.create!(name: "Root EdTech Co", company_type: "Product", user: user, industry: edtech) }
  let!(:family_company) { Company.create!(name: "Family Co", company_type: "Product", user: user, industry: family_engagement) }
  let!(:k12_company) { Company.create!(name: "K12 Co", company_type: "Product", user: user, industry: k12) }
  let!(:other_company) { Company.create!(name: "Unrelated Co", company_type: "Product", user: user, industry: create(:industry, name: "FinTech")) }

  describe "GET /companies" do
    it "shows the industry hierarchy in the filter and in each row" do
      get companies_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("EdTech: Family Engagement")
    end

    it "filters by a top-level industry, including its segments" do
      get companies_path, params: { industry_id: edtech.id }

      expect(response.body).to include("Root EdTech Co", "Family Co", "K12 Co")
      expect(response.body).not_to include("Unrelated Co")
    end

    it "filters by a segment only" do
      get companies_path, params: { industry_id: family_engagement.id }

      expect(response.body).to include("Family Co")
      expect(response.body).not_to include("K12 Co", "Root EdTech Co", "Unrelated Co")
    end

    it "sorts by industry, top-level first then segment" do
      get companies_path, params: { sort: "industry", direction: "asc" }

      expect(response).to have_http_status(:ok)
      body = response.body
      expect(body.index("Root EdTech Co")).to be < body.index("Family Co")
      expect(body.index("Family Co")).to be < body.index("K12 Co")
      expect(body.index("K12 Co")).to be < body.index("Unrelated Co")
    end

    it "ignores a sort column that is not whitelisted" do
      get companies_path, params: { sort: "id; DROP TABLE companies", direction: "asc" }

      expect(response).to have_http_status(:ok)
    end

    it "combines the industry filter with a technology filter without duplicating rows" do
      technology = Technology.create!(name: "Ruby on Rails", category: "Backend")
      2.times do |index|
        opportunity = Opportunity.create!(company: family_company, position_title: "Role #{index}", role_type: "software_engineer")
        OpportunityTechnology.create!(opportunity: opportunity, technology: technology)
      end

      get companies_path, params: { industry_id: edtech.id, technology: "Ruby on Rails", sort: "industry" }

      expect(response).to have_http_status(:ok)
      expect(response.body.scan("Family Co").size).to eq(1)
    end
  end

  describe "PATCH /companies/:id" do
    it "assigns the industry by id" do
      patch company_path(other_company), params: { company: { industry_id: family_engagement.id } }

      expect(other_company.reload.industry).to eq(family_engagement)
    end
  end
end
