require "rails_helper"

RSpec.describe "ResourceGuideQuestions", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /resource_guide_questions/new" do
    it "offers the guide's existing section choices and a new-section field" do
      get new_resource_guide_question_path(guide_type: "technical")

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Architecture &amp; Design", "Debugging &amp; Reliability", "Or create a new section")
    end

    it "includes previously created sections for the same guide" do
      user.resource_guide_questions.create!(guide_type: "technical", section_title: "Distributed Systems", question: "How do you partition data?")
      user.resource_guide_questions.create!(guide_type: "behavioral", section_title: "Mentoring", question: "How did you mentor a teammate?")

      get new_resource_guide_question_path(guide_type: "technical")

      expect(response.body).to include("Distributed Systems")
      expect(response.body).not_to include(">Mentoring</option>")
    end
  end

  describe "POST /resource_guide_questions" do
    it "places a question under a selected existing section" do
      post resource_guide_questions_path, params: {
        resource_guide_question: {
          guide_type: "technical",
          section_title: "Debugging & Reliability",
          question: "How do you investigate a memory leak?"
        }
      }

      question = user.resource_guide_questions.last
      expect(response).to redirect_to(technical_guide_path)
      expect(question.section_title).to eq("Debugging & Reliability")

      get technical_guide_path
      expect(response.body).to include("How do you investigate a memory leak?")
      expect(response.body.index(">Debugging & Reliability</h2>")).to be < response.body.index("How do you investigate a memory leak?")
      expect(response.body).not_to include("Added Questions")
    end

    it "creates a new section and gives it precedence over a selected section" do
      post resource_guide_questions_path, params: {
        resource_guide_question: {
          guide_type: "technical",
          section_title: "Architecture & Design",
          new_section_title: "Distributed Systems",
          question: "How do you design partitioning?"
        }
      }

      question = user.resource_guide_questions.last
      expect(question.section_title).to eq("Distributed Systems")

      get technical_guide_path
      expect(response.body).to include("Distributed Systems", "How do you design partitioning?")
      expect(response.body.index("Distributed Systems")).to be < response.body.index("How do you design partitioning?")
    end
  end
end
