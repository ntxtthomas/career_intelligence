require "rails_helper"

RSpec.describe "Admin::Industries", type: :request do
  let(:admin_user) { create(:user) }
  let(:demo_user) { create(:user, :demo) }

  let!(:edtech) { create(:industry, name: "EdTech", domain_match: "deep") }
  let!(:k12) { create(:segment, name: "K-12", parent: edtech) }

  describe "access control" do
    it "redirects unauthenticated users to sign in" do
      get admin_industries_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "blocks demo users from every action" do
      sign_in demo_user

      get admin_industries_path
      expect(response).to redirect_to(dashboard_path)

      expect { post admin_industries_path, params: { industry: { name: "Nope" } } }.not_to change(Industry, :count)
      expect(response).to redirect_to(dashboard_path)

      expect { delete admin_industry_path(k12) }.not_to change(Industry, :count)
    end
  end

  describe "as an admin" do
    before { sign_in admin_user }

    it "links to Industries from both the desktop and the mobile menu" do
      get dashboard_path

      expect(response.body.scan(%(href="#{admin_industries_path}")).size).to eq(2)
      mobile_menu = response.body[/data-nav-target="menu".*?<\/nav>/m]
      expect(mobile_menu).to include(%(href="#{admin_industries_path}"))
    end

    it "lists industries with their segments, inherited domain match and company counts" do
      Company.create!(name: "Kid Co", company_type: "Product", user: admin_user, industry: k12)

      get admin_industries_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("EdTech", "K-12", "Deep (inherited)", "1 segment")
      expect(response.body.index("EdTech")).to be < response.body.index("K-12")
    end

    it "makes rows clickable to the show page and has no per-row buttons" do
      get admin_industries_path

      expect(response.body).to include(%(data-href="#{admin_industry_path(edtech)}"), %(data-href="#{admin_industry_path(k12)}"))
      expect(response.body).not_to include("Delete", "Add segment")
      expect(response.body).not_to include(edit_admin_industry_path(edtech))
    end

    it "renders segment rows hidden, collapsed under a toggle on their parent" do
      get admin_industries_path

      expect(response.body).to include(%(data-controller="industry-group"))
      expect(response.body).to include(%(aria-expanded="false"))
      expect(response.body).to match(/<tr id="industry_#{k12.id}"[^>]*data-industry-group-target="segment" hidden/m)
    end

    describe "sorting top-level industries" do
      let!(:alpha) { create(:industry, name: "Alpha", domain_match: "none") }
      let!(:zulu) { create(:industry, name: "Zulu", domain_match: "adjacent") }

      before do
        Company.create!(name: "Alpha Co 1", company_type: "Product", user: admin_user, industry: alpha)
        Company.create!(name: "Alpha Co 2", company_type: "Product", user: admin_user, industry: alpha)
        Company.create!(name: "Kid Co", company_type: "Product", user: admin_user, industry: k12)
      end

      def names_in_order(*names)
        names.sort_by { |name| response.body.index(">#{name}<") }
      end

      it "sorts by name ascending by default and descending on request" do
        get admin_industries_path
        expect(names_in_order("Alpha", "EdTech", "Zulu")).to eq(%w[Alpha EdTech Zulu])

        get admin_industries_path, params: { sort: "name", direction: "desc" }
        expect(names_in_order("Alpha", "EdTech", "Zulu")).to eq(%w[Zulu EdTech Alpha])
      end

      it "sorts by company count, counting a parent's segments toward its total" do
        get admin_industries_path, params: { sort: "companies", direction: "desc" }

        expect(names_in_order("Alpha", "EdTech", "Zulu")).to eq(%w[Alpha EdTech Zulu])
      end

      it "sorts by how closely the domain matches" do
        get admin_industries_path, params: { sort: "domain_match", direction: "desc" }

        expect(names_in_order("Alpha", "EdTech", "Zulu")).to eq(%w[EdTech Zulu Alpha])
      end

      it "keeps segments under their parent regardless of sort" do
        get admin_industries_path, params: { sort: "name", direction: "desc" }

        expect(response.body.index("K-12")).to be > response.body.index(">EdTech<")
        expect(response.body.index("K-12")).to be < response.body.index(">Alpha<")
      end

      it "ignores an unknown sort column" do
        get admin_industries_path, params: { sort: "id; DROP TABLE industries" }

        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/industries/:id" do
      it "shows a top-level industry with its segments and action buttons" do
        Company.create!(name: "Kid Co", company_type: "Product", user: admin_user, industry: k12)
        edtech.update!(definition: "Software and services that support teaching and learning.")

        get admin_industry_path(edtech)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("EdTech", "K-12", "Deep", "Software and services that support teaching and learning.")
        expect(response.body).to include("Edit this industry", "Add segment", "Back to industries", "Destroy this industry")
        expect(response.body).to include(companies_path(industry_id: edtech.id))
      end

      it "shows a segment with a link to its parent and no Add segment button" do
        k12.update!(definition: "Products and services for kindergarten through grade 12.")

        get admin_industry_path(k12)

        expect(response.body).to include("Parent industry", admin_industry_path(edtech), "Products and services for kindergarten through grade 12.")
        expect(response.body).not_to include("Add segment")
      end
    end

    it "creates a top-level industry" do
      expect {
        post admin_industries_path, params: { industry: { name: "Logistics", parent_id: "", domain_match: "" } }
      }.to change(Industry.roots, :count).by(1)

      industry = Industry.find_by!(name: "Logistics")
      expect(industry.parent).to be_nil
      expect(industry.domain_match).to be_nil
      expect(response).to redirect_to(admin_industry_path(industry))
    end

    it "creates a segment under a parent" do
      expect {
        post admin_industries_path, params: { industry: { name: "Special Education", parent_id: edtech.id, definition: "Education services for students with additional learning needs." } }
      }.to change(edtech.children, :count).by(1)

      expect(Industry.find_by!(name: "Special Education").definition).to eq("Education services for students with additional learning needs.")
    end

    it "pre-selects the parent on the new segment form" do
      get new_admin_industry_path(parent_id: edtech.id)

      expect(response.body).to include("New segment of EdTech")
    end

    it "re-renders the form with errors for an invalid industry" do
      post admin_industries_path, params: { industry: { name: "edtech", parent_id: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("has already been taken")
    end

    it "rejects a segment of a segment" do
      post admin_industries_path, params: { industry: { name: "Deep Child", parent_id: k12.id } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("must be a top-level industry")
    end

    it "updates an industry" do
      patch admin_industry_path(k12), params: { industry: { name: "K-12 Schools", domain_match: "adjacent", definition: "Schooling from kindergarten through grade 12." } }

      expect(k12.reload).to have_attributes(name: "K-12 Schools", domain_match: "adjacent", definition: "Schooling from kindergarten through grade 12.")
      expect(response).to redirect_to(admin_industry_path(k12))
    end

    it "deletes an unused industry" do
      expect { delete admin_industry_path(k12) }.to change(Industry, :count).by(-1)
      expect(response).to redirect_to(admin_industries_path)
    end

    it "refuses to delete an industry that has segments and returns to its show page" do
      expect { delete admin_industry_path(edtech) }.not_to change(Industry, :count)

      expect(response).to redirect_to(admin_industry_path(edtech))
      follow_redirect!
      expect(response.body).to include("dependent")
    end

    it "refuses to delete an industry that companies use" do
      Company.create!(name: "Kid Co", company_type: "Product", user: admin_user, industry: k12)

      expect { delete admin_industry_path(k12) }.not_to change(Industry, :count)
    end
  end
end
