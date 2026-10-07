require "rails_helper"

RSpec.describe "Navigation", type: :request do
  let(:admin_user) { create(:user) }
  let!(:demo_user) { create(:user, :demo) }

  def nav_html(body)
    body[%r{<nav.*?</nav>}m]
  end

  describe "signed-in admin nav" do
    before { sign_in admin_user }

    it "shows the six top-level items and the account menu entries" do
      get dashboard_path

      nav = nav_html(response.body)
      expect(nav).to include(">Companies<")
      expect(nav).to include(">Opportunities<")
      expect(nav).to include(">Contacts<")
      expect(nav).to include(">Interview Hub<")
      expect(nav).to include(">Experiments<")
      expect(nav).to include(">Account<")

      expect(nav).to include(">Industries<")
      expect(nav).to include(">Pulse Admin<")
      expect(nav).to include(">Sign out<")
    end

    it "renders the account button and menu as accessible toggles" do
      get dashboard_path

      nav = nav_html(response.body)
      expect(nav).to match(/<button[^>]*aria-expanded="false"[^>]*aria-controls="account-menu"/)
      expect(nav).to match(/<button[^>]*aria-expanded="false"[^>]*aria-controls="mobile-nav-menu"/)
    end

    it "points Interview Hub at the interview sessions index" do
      get dashboard_path

      expect(nav_html(response.body)).to include(%(href="#{interview_sessions_path}"))
    end
  end

  describe "signed-in non-admin (demo) nav" do
    before { sign_in demo_user }

    it "shows Sign out but hides admin-only items" do
      get dashboard_path

      nav = nav_html(response.body)
      expect(nav).to include(">Sign out<")
      expect(nav).not_to include(">Industries<")
      expect(nav).not_to include(">Pulse Admin<")
    end
  end

  describe "guest nav" do
    it "shows no Sign out and no admin items, with a quiet Sign in link instead" do
      get companies_path

      nav = nav_html(response.body)
      expect(nav).not_to include(">Sign out<")
      expect(nav).not_to include(">Industries<")
      expect(nav).not_to include(">Pulse Admin<")
      expect(nav).not_to include(">Account<")
      expect(nav).to include(">Sign in<")
    end

    it "still shows the five non-account top-level items" do
      get companies_path

      nav = nav_html(response.body)
      expect(nav).to include(">Companies<")
      expect(nav).to include(">Opportunities<")
      expect(nav).to include(">Contacts<")
      expect(nav).to include(">Interview Hub<")
      expect(nav).to include(">Experiments<")
    end
  end
end
