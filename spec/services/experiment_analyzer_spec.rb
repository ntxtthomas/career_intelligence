require "rails_helper"

RSpec.describe ExperimentAnalyzer do
  let(:user) { create(:user) }
  let!(:company) { Company.create!(name: "Analyzer Co #{SecureRandom.hex(4)}", company_type: "Product", user: user) }

  describe "#conversion_by_channel" do
    it "returns count, interviewed, and rate per channel" do
      referral_with_interview = Opportunity.create!(company: company, role_type: "software_engineer", acquisition_channel: "referral")
      referral_without_interview = Opportunity.create!(company: company, role_type: "software_engineer", acquisition_channel: "referral")
      cold_without_interview = Opportunity.create!(company: company, role_type: "software_engineer", acquisition_channel: "cold_application")

      InterviewSession.create!(opportunity: referral_with_interview, stage: "recruiter", scheduled_at: Time.current, format: "phone", status: "completed")

      analyzer = described_class.new(Opportunity.where(id: [ referral_with_interview.id, referral_without_interview.id, cold_without_interview.id ]))
      result = analyzer.conversion_by_channel

      expect(result["referral"]).to eq(count: 2, interviewed: 1, rate: 50.0)
      expect(result["cold_application"]).to eq(count: 1, interviewed: 0, rate: 0.0)
    end
  end

  describe "#conversion_by_domain_match" do
    it "returns count, interviewed, and rate per domain match" do
      deep_with_interview = Opportunity.create!(company: company, role_type: "software_engineer", domain_match: "deep")
      deep_without_interview = Opportunity.create!(company: company, role_type: "software_engineer", domain_match: "deep")
      none_without_interview = Opportunity.create!(company: company, role_type: "software_engineer", domain_match: "none")

      InterviewSession.create!(opportunity: deep_with_interview, stage: "recruiter", scheduled_at: Time.current, format: "phone", status: "completed")

      analyzer = described_class.new(Opportunity.where(id: [ deep_with_interview.id, deep_without_interview.id, none_without_interview.id ]))
      result = analyzer.conversion_by_domain_match

      expect(result["deep"]).to eq(count: 2, interviewed: 1, rate: 50.0)
      expect(result["none"]).to eq(count: 1, interviewed: 0, rate: 0.0)
    end
  end

  describe "#conversion_by_fit_map" do
    it "returns count, interviewed, and rate grouped by boolean fit_map_used" do
      with_map_and_interview = Opportunity.create!(company: company, role_type: "software_engineer", fit_map_used: true)
      without_map = Opportunity.create!(company: company, role_type: "software_engineer", fit_map_used: false)

      InterviewSession.create!(opportunity: with_map_and_interview, stage: "recruiter", scheduled_at: Time.current, format: "phone", status: "completed")

      analyzer = described_class.new(Opportunity.where(id: [ with_map_and_interview.id, without_map.id ]))
      result = analyzer.conversion_by_fit_map

      expect(result[true]).to eq(count: 1, interviewed: 1, rate: 100.0)
      expect(result[false]).to eq(count: 1, interviewed: 0, rate: 0.0)
    end
  end

  describe "#response_rate_breakdown" do
    it "returns raw and human response rates with counts and denominators" do
      human = Opportunity.create!(company: company, role_type: "software_engineer", response_type: "human")
      automated = Opportunity.create!(company: company, role_type: "software_engineer", response_type: "automated")
      no_response = Opportunity.create!(company: company, role_type: "software_engineer", response_type: "no_response")
      no_response_two = Opportunity.create!(company: company, role_type: "software_engineer", response_type: "no_response")

      analyzer = described_class.new(Opportunity.where(id: [ human.id, automated.id, no_response.id, no_response_two.id ]))
      result = analyzer.response_rate_breakdown

      expect(result[:raw_response]).to eq(count: 2, denominator: 4, rate: 50.0)
      expect(result[:human_response]).to eq(count: 1, denominator: 4, rate: 25.0)
    end
  end
end
