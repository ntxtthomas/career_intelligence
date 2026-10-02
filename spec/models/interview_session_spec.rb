require "rails_helper"

RSpec.describe InterviewSession, type: :model do
  let(:user) { create(:user) }
  let(:company) { Company.create!(name: "Interview Co #{SecureRandom.hex(4)}", company_type: "Product", user: user) }

  def create_session(opportunity)
    InterviewSession.create!(opportunity: opportunity, stage: "recruiter", scheduled_at: Time.current, format: "phone", status: "planned")
  end

  describe "marking the opportunity as responded" do
    %w[unknown no_response automated].each do |previous|
      it "sets a #{previous} response to human when a session is created" do
        opportunity = Opportunity.create!(company: company, role_type: "software_engineer", response_type: previous)

        create_session(opportunity)

        expect(opportunity.reload.response_type).to eq("human")
      end
    end

    it "leaves an existing human response alone" do
      opportunity = Opportunity.create!(company: company, role_type: "software_engineer", response_type: "human")

      expect { create_session(opportunity) }.not_to(change { opportunity.reload.updated_at })
    end

    it "does not re-run the opportunity's save callbacks" do
      opportunity = Opportunity.create!(company: company, role_type: "software_engineer", salary_range: "$110k-$125k")
      allow_any_instance_of(Opportunity).to receive(:standardize_salary_range).and_raise("standardize_salary_range should not run")

      expect { create_session(opportunity) }.not_to raise_error
    end
  end
end
