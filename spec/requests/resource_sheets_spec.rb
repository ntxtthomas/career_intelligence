require "rails_helper"

RSpec.describe "ResourceSheets", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let!(:company) do
    Company.create!(
      name: "Prep Corp",
      industry: "Technology",
      location: "Remote",
      website: "https://prep.example",
      company_type: "Product",
      user: user
    )
  end

  let!(:opportunity) do
    Opportunity.create!(
      company: company,
      position_title: "Senior Engineer",
      role_type: "software_engineer",
      status: "applied",
      application_date: Date.current
    )
  end

  let!(:resource_sheet) do
    ResourceSheet.create!(
      title: "SE Interview One Pager",
      resource_type: "interview_prep",
      role_type: "software_engineer",
      company: company,
      opportunity: opportunity,
      user: user,
      version_label: "v1",
      active: true,
      about_me_content: "About me summary",
      why_company_content: "Why this company",
      why_me_content: "Why me",
      salary_content: "Salary framework"
    )
  end

  describe "GET /index" do
    it "returns success" do
      get resource_sheets_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Resources")
    end
  end

  describe "GET /show" do
    it "returns success" do
      get resource_sheet_path(resource_sheet)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Cue / Topic")
      expect(response.body).to include("Main Content")
      expect(response.body).to include("Bullets / Prompts")
    end
  end

  describe "GET /new" do
    it "returns success" do
      get new_resource_sheet_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "creates resource sheet" do
      expect do
        post resource_sheets_path, params: {
          resource_sheet: {
            title: "PM Interview One Pager",
            resource_type: "interview_prep",
            role_type: "product_manager",
            company_id: company.id,
            opportunity_id: opportunity.id,
            version_label: "v2",
            active: true,
            about_me_content: "PM about me",
            about_me_bullets: "bullet 1\nbullet 2",
            why_company_content: "pm company fit",
            why_me_content: "pm why me",
            salary_content: "pm salary"
          }
        }
      end.to change(ResourceSheet, :count).by(1)

      expect(response).to redirect_to(resource_sheet_path(ResourceSheet.last))
    end
  end

  describe "POST /generate_from_opportunity" do
    it "creates a draft resource and redirects to edit" do
      expect do
        post generate_from_opportunity_resource_sheets_path, params: { opportunity_id: opportunity.id }
      end.to change(ResourceSheet, :count).by(1)

      generated = ResourceSheet.order(:created_at).last
      expect(generated.opportunity_id).to eq(opportunity.id)
      expect(generated.company_id).to eq(company.id)
      expect(generated.resource_type).to eq("interview_prep")
      expect(response).to redirect_to(edit_resource_sheet_path(generated))
    end
  end

  describe "PATCH /update" do
    it "updates resource sheet" do
      patch resource_sheet_path(resource_sheet), params: {
        resource_sheet: {
          title: "Updated One Pager",
          version_label: "v3"
        }
      }

      expect(response).to redirect_to(resource_sheet_path(resource_sheet))
      expect(resource_sheet.reload.title).to eq("Updated One Pager")
    end
  end

  describe "DELETE /destroy" do
    it "deletes resource sheet" do
      expect do
        delete resource_sheet_path(resource_sheet)
      end.to change(ResourceSheet, :count).by(-1)

      expect(response).to redirect_to(resource_sheets_path)
    end
  end
end
