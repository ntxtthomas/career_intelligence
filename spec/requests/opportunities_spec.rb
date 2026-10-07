require "rails_helper"

RSpec.describe "Opportunities", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  def domain_match_select_html(body)
    body[/<select[^>]*id="opportunity_domain_match"[^>]*>.*?<\/select>/m]
  end

  let!(:company) do
    Company.create!(
      name: "FilterCo",
      industry: create(:industry, name: "Technology"),
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

    it "sorts opportunities by company industry" do
      retail_company = Company.create!(
        name: "RetailCo",
        industry: create(:industry, name: "Retail"),
        company_type: "Product",
        user: user
      )
      Opportunity.create!(
        company: retail_company,
        position_title: "Retail Role",
        role_type: "software_engineer"
      )

      get opportunities_path, params: { sort: "industry", direction: "asc" }

      expect(response).to have_http_status(:ok)
      expect(response.body.index("Retail Role")).to be < response.body.index("Applied Role")
    end
  end

  describe "GET /opportunities/new" do
    it "renders the current opportunity source options" do
      get new_opportunity_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Wellfound")
      expect(response.body).to include("Toptal")
      expect(response.body).to include("lemon.io")
      expect(response.body).to include("Braintrust")
      expect(response.body).to include("gun.io")
      expect(response.body).to include("Upwork")
      expect(response.body).not_to include(">Monster<")
    end

    it "renders the paste tech stack control" do
      get new_opportunity_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Paste Tech Stack")
      expect(response.body).to include("data-controller=\"technology-picker\"")
      expect(response.body).to include("data-action=\"technology-picker#apply\"")
    end

    it "offers an auto-resolve option instead of unknown on the domain match select" do
      get new_opportunity_path

      expect(response).to have_http_status(:ok)
      expect(domain_match_select_html(response.body)).to include("Auto (segment, else industry)")
      expect(domain_match_select_html(response.body)).not_to include(">Unknown<")
    end
  end

  describe "GET /opportunities/:id/edit" do
    it "keeps unknown as a selectable domain match, since the default callback is create-only" do
      get edit_opportunity_path(applied_opportunity)

      expect(response).to have_http_status(:ok)
      expect(domain_match_select_html(response.body)).to include(">Unknown<")
      expect(domain_match_select_html(response.body)).not_to include("Auto (segment, else industry)")
    end
  end

  describe "POST /opportunities with the domain match left blank (auto-resolve)" do
    it "resolves to the company's segment domain_match when the segment has one set" do
      root = create(:industry, name: "EdTech Root", domain_match: "deep")
      segment = create(:segment, name: "K-12", parent: root, domain_match: "direct")
      segment_company = Company.create!(name: "Segment Co #{SecureRandom.hex(4)}", industry: segment, company_type: "Product", user: user)

      expect {
        post opportunities_path, params: {
          opportunity: { company_id: segment_company.id, role_type: "software_engineer", position_title: "Auto Segment Role", domain_match: "" }
        }
      }.to change(Opportunity, :count).by(1)

      expect(response).to redirect_to(Opportunity.last)
      expect(Opportunity.last.domain_match).to eq("direct")
    end

    it "falls back to the parent industry's domain_match when the segment has none set" do
      root = create(:industry, name: "FinTech Root", domain_match: "adjacent")
      segment = create(:segment, name: "Payments", parent: root)
      segment_company = Company.create!(name: "Segment Co 2 #{SecureRandom.hex(4)}", industry: segment, company_type: "Product", user: user)

      post opportunities_path, params: {
        opportunity: { company_id: segment_company.id, role_type: "software_engineer", position_title: "Auto Industry Role", domain_match: "" }
      }

      expect(response).to redirect_to(Opportunity.last)
      expect(Opportunity.last.domain_match).to eq("adjacent")
    end

    it "falls back to unknown when neither the segment nor the industry has a domain_match set" do
      post opportunities_path, params: {
        opportunity: { company_id: company.id, role_type: "software_engineer", position_title: "Auto Unknown Role", domain_match: "" }
      }

      expect(response).to redirect_to(Opportunity.last)
      expect(Opportunity.last.domain_match).to eq("unknown")
    end

    it "does not raise a NOT NULL error when the blank option is submitted" do
      expect {
        post opportunities_path, params: {
          opportunity: { company_id: company.id, role_type: "software_engineer", position_title: "No Error Role", domain_match: "" }
        }
      }.not_to raise_error

      expect(response).to have_http_status(:found)
      expect(Opportunity.last.domain_match).to be_present
    end
  end
end
