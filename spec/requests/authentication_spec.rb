require "rails_helper"

RSpec.describe "Authentication", type: :request do
  let(:user) { create(:user) }
  let!(:demo_user) { create(:user, :demo) }

  describe "write protection for unauthenticated visitors" do
    let!(:company) do
      Company.create!(
        name: "Demo Corp",
        company_type: "Product",
        user: demo_user
      )
    end

    it "allows GET requests without authentication" do
      get companies_path
      expect(response).to have_http_status(:ok)
    end

    it "blocks POST requests without authentication" do
      post companies_path, params: { company: { name: "New Co", company_type: "Product" } }
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("This app is for demo only, save is not allowed.")
    end

    it "blocks PATCH requests without authentication" do
      patch company_path(company), params: { company: { name: "Updated" } }
      expect(response).to redirect_to(root_path)
    end

    it "blocks DELETE requests without authentication" do
      delete company_path(company)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "authenticated user access" do
    before { sign_in user }

    let!(:company) do
      Company.create!(name: "My Corp", company_type: "Product", user: user)
    end

    it "allows POST requests" do
      expect {
        post companies_path, params: { company: { name: "New Auth Co", company_type: "Product" } }
      }.to change(Company, :count).by(1)
    end

    it "allows PATCH requests" do
      patch company_path(company), params: { company: { name: "Updated Corp" } }
      expect(company.reload.name).to eq("Updated Corp")
    end

    it "allows DELETE requests" do
      expect {
        delete company_path(company)
      }.to change(Company, :count).by(-1)
    end
  end

  describe "data scoping" do
    let!(:owner_company) { Company.create!(name: "OwnerCorp99", company_type: "Product", user: user) }
    let!(:demo_company) { Company.create!(name: "DemoCorp99", company_type: "Product", user: demo_user) }

    it "shows demo data to unauthenticated visitors" do
      get companies_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("DemoCorp99")
      expect(response.body).not_to include("OwnerCorp99")
    end

    it "shows owner data to authenticated user" do
      sign_in user
      get companies_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("OwnerCorp99")
      expect(response.body).not_to include("DemoCorp99")
    end
  end
end
