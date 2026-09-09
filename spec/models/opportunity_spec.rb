require "rails_helper"

RSpec.describe Opportunity, type: :model do
  let(:user) { create(:user) }

  describe "experiment enums" do
    let!(:company) do
      Company.create!(name: "EnumCo #{SecureRandom.hex(4)}", company_type: "Product", user: user)
    end

    it "accepts all defined acquisition_channel values" do
      %w[cold_application recruiter_inbound referral direct_outreach network other unknown].each do |value|
        opportunity = Opportunity.new(company: company, role_type: "software_engineer", acquisition_channel: value)
        expect(opportunity.acquisition_channel).to eq(value)
      end
    end

    it "accepts all defined domain_match values" do
      %w[none adjacent direct deep unknown].each do |value|
        opportunity = Opportunity.new(company: company, role_type: "software_engineer", domain_match: value)
        expect(opportunity.domain_match).to eq(value)
      end
    end

    it "accepts all defined response_type values" do
      %w[human automated no_response unknown].each do |value|
        opportunity = Opportunity.new(company: company, role_type: "software_engineer", response_type: value)
        expect(opportunity.response_type).to eq(value)
      end
    end
  end

  describe "#default_domain_match_from_company" do
    it "defaults domain_match from the company's suggested_domain_match on create when unset" do
      company = Company.create!(name: "Proptech Co #{SecureRandom.hex(4)}", industry: "PropTech", company_type: "Product", user: user)

      opportunity = Opportunity.create!(company: company, role_type: "software_engineer")

      expect(opportunity.domain_match).to eq("deep")
    end

    it "falls back to unknown when the company has no suggested match" do
      company = Company.create!(name: "Mystery Co #{SecureRandom.hex(4)}", industry: "Widgets", company_type: "Product", user: user)

      opportunity = Opportunity.create!(company: company, role_type: "software_engineer")

      expect(opportunity.domain_match).to eq("unknown")
    end

    it "does not override an explicitly-set domain_match on create" do
      company = Company.create!(name: "Fintech Co #{SecureRandom.hex(4)}", industry: "FinTech", company_type: "Product", user: user)

      opportunity = Opportunity.create!(company: company, role_type: "software_engineer", domain_match: "direct")

      expect(opportunity.domain_match).to eq("direct")
    end

    it "does not run on update" do
      company = Company.create!(name: "Edtech Co #{SecureRandom.hex(4)}", industry: "EdTech", company_type: "Product", user: user)
      other_company = Company.create!(name: "Generic Co #{SecureRandom.hex(4)}", industry: "Generic SaaS", company_type: "Product", user: user)
      opportunity = Opportunity.create!(company: company, role_type: "software_engineer")
      expect(opportunity.domain_match).to eq("deep")

      opportunity.update!(company: other_company)

      expect(opportunity.domain_match).to eq("deep")
    end
  end
end
