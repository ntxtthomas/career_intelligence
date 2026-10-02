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

  describe "industry breakdowns" do
    let(:edtech) { create(:industry, name: "EdTech") }
    let(:family_engagement) { create(:segment, name: "Family Engagement", parent: edtech) }
    let(:k12) { create(:segment, name: "K-12", parent: edtech) }
    let(:fintech) { create(:industry, name: "FinTech") }

    def company_in(industry, size: "11-50")
      Company.create!(name: "Co #{SecureRandom.hex(4)}", company_type: "Product", user: user, industry: industry, size: size)
    end

    def opportunity_for(company, response_type: "no_response", interviewed: false)
      opportunity = Opportunity.create!(company: company, role_type: "software_engineer", response_type: response_type)
      if interviewed
        InterviewSession.create!(opportunity: opportunity, stage: "recruiter", scheduled_at: Time.current, format: "phone", status: "completed")
      end
      opportunity
    end

    let!(:opportunities) do
      [
        opportunity_for(company_in(edtech), response_type: "human", interviewed: true),
        opportunity_for(company_in(family_engagement), response_type: "human"),
        opportunity_for(company_in(family_engagement)),
        opportunity_for(company_in(k12)),
        opportunity_for(company_in(fintech)),
        opportunity_for(Company.create!(name: "No Industry #{SecureRandom.hex(4)}", company_type: "Product", user: user))
      ]
    end

    let(:analyzer) { described_class.new(Opportunity.where(id: opportunities.map(&:id))) }

    describe "#response_interview_by_industry" do
      it "rolls segments up into their top-level industry and keeps companies without one as nil" do
        result = analyzer.response_interview_by_industry

        expect(result["EdTech"]).to include(count: 4, responded: 2, interviewed: 1)
        expect(result["FinTech"]).to include(count: 1, responded: 0, interviewed: 0, response_rate: 0.0)
        expect(result[nil]).to include(count: 1)
        expect(result.keys).not_to include("Family Engagement", "K-12")
      end
    end

    describe "#response_interview_by_segment" do
      it "drills down to segments keyed by [industry, segment] and ignores companies tagged at the top level" do
        result = analyzer.response_interview_by_segment

        expect(result.keys).to contain_exactly([ "EdTech", "Family Engagement" ], [ "EdTech", "K-12" ])
        expect(result[[ "EdTech", "Family Engagement" ]]).to include(count: 2, responded: 1, response_rate: 50.0)
        expect(result[[ "EdTech", "K-12" ]]).to include(count: 1, responded: 0, response_rate: 0.0)
      end
    end

    describe "#response_interview_by_industry_and_size" do
      it "cross-tabs by top-level industry and drops combinations below min_sample" do
        result = analyzer.response_interview_by_industry_and_size(min_sample: 3)

        expect(result.keys).to eq([ [ "EdTech", "11-50" ] ])
        expect(result[[ "EdTech", "11-50" ]]).to include(count: 4)
      end
    end
  end
end
