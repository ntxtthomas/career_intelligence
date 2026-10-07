require "rails_helper"

RSpec.describe "StarStories", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /star_stories" do
    it "returns success" do
      get star_stories_path
      expect(response).to have_http_status(:ok)
    end

    it "renders the Interview Hub sub-nav with STAR Stories active" do
      get star_stories_path

      expect(response.body).to include(%(href="#{interview_sessions_path}"))
      expect(response.body).to include(%(href="#{resource_sheets_path}"))
      expect(response.body).to include(%(href="#{guides_path}"))
      expect(response.body[/<a[^>]*href="#{star_stories_path}"[^>]*>STAR Stories<\/a>/]).to include('aria-current="page"')
    end
  end
end
