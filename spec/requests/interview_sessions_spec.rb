require "rails_helper"

RSpec.describe "InterviewSessions", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  let!(:company) { Company.create!(name: "Interview Co #{SecureRandom.hex(4)}", industry: "Technology", location: "Remote", website: "https://example.com", company_type: "Product", user: user) }
  let!(:opportunity) { Opportunity.create!(company: company, position_title: "Senior Engineer", role_type: "software_engineer") }
  let!(:contact) { Contact.create!(company: company, name: "Taylor Recruiter", email: "taylor@example.com") }

  let!(:interview_session) do
    InterviewSession.create!(
      opportunity: opportunity,
      contact: contact,
      stage: "recruiter",
      scheduled_at: Time.zone.parse("2026-03-01 10:00"),
      duration_minutes: 30,
      format: "phone",
      status: "planned",
      overall_signal: "neutral",
      confidence_score: 6,
      questions_they_asked: "Tell me about your background",
      questions_i_asked: "What does success look like in 90 days?",
      follow_ups: "Send thank-you note",
      next_steps: "Await recruiter update"
    )
  end

  describe "GET /index" do
    it "returns http success" do
      get interview_sessions_path
      expect(response).to have_http_status(:ok)
    end

    it "returns csv when requested" do
      get interview_sessions_path(format: :csv)

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      expect(response.body).to include("Company")
      expect(response.body).to include("Opportunity")
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_interview_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /create" do
    it "creates an interview session" do
      expect do
        post interview_sessions_path, params: {
          interview_session: {
            opportunity_id: opportunity.id,
            contact_id: contact.id,
            stage: "technical",
            scheduled_at: "2026-03-10T10:00",
            duration_minutes: 45,
            format: "video",
            status: "planned",
            overall_signal: "yes",
            confidence_score: 8,
            questions_they_asked: "How do you debug production issues?",
            questions_i_asked: "How does your team handle ownership?",
            follow_ups: "Send portfolio",
            next_steps: "Panel interview"
          }
        }
      end.to change(InterviewSession, :count).by(1)

      expect(response).to redirect_to(interview_session_path(InterviewSession.last))
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get interview_session_path(interview_session)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_interview_session_path(interview_session)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /update" do
    it "updates the interview session" do
      patch interview_session_path(interview_session), params: {
        interview_session: {
          stage: "hiring_manager",
          format: "onsite",
          status: "completed",
          confidence_score: 9
        }
      }

      expect(response).to redirect_to(interview_session_path(interview_session))
      expect(interview_session.reload.stage).to eq("hiring_manager")
      expect(interview_session.format).to eq("onsite")
      expect(interview_session.status).to eq("completed")
      expect(interview_session.confidence_score).to eq(9)
    end
  end

  describe "DELETE /destroy" do
    it "deletes the interview session" do
      expect do
        delete interview_session_path(interview_session)
      end.to change(InterviewSession, :count).by(-1)

      expect(response).to redirect_to(interview_sessions_path)
    end
  end
end
