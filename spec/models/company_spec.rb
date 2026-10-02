require "rails_helper"

RSpec.describe Company, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "validates name presence" do
      company = Company.new(name: nil, company_type: "Product", user: user)

      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end

    it "validates name uniqueness case-insensitively" do
      unique_name = "Acme Corp #{SecureRandom.hex(4)}"
      Company.create!(name: unique_name, company_type: "Product", user: user)
      duplicate = Company.new(name: unique_name.downcase, company_type: "Product", user: user)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "normalizes whitespace in name before validation" do
      company = Company.new(name: "  New   Co  ", company_type: "Product", user: user)

      company.validate

      expect(company.name).to eq("New Co")
    end
  end

  describe "#suggested_domain_match" do
    it "returns the industry's domain match" do
      company = Company.new(industry: build(:industry, domain_match: "deep"))

      expect(company.suggested_domain_match).to eq("deep")
    end

    it "falls back to the parent industry when a segment has no match of its own" do
      parent = create(:industry, domain_match: "deep")
      company = Company.new(industry: create(:segment, parent: parent))

      expect(company.suggested_domain_match).to eq("deep")
    end

    it "prefers a segment's own domain match over its parent's" do
      parent = create(:industry, domain_match: "deep")
      company = Company.new(industry: create(:segment, parent: parent, domain_match: "adjacent"))

      expect(company.suggested_domain_match).to eq("adjacent")
    end

    it "returns nil when the industry has no domain match" do
      company = Company.new(industry: build(:industry))

      expect(company.suggested_domain_match).to be_nil
    end

    it "returns nil when industry is blank" do
      company = Company.new(industry: nil)

      expect(company.suggested_domain_match).to be_nil
    end
  end

  describe ".in_industry" do
    let(:edtech) { create(:industry, name: "EdTech") }
    let(:family_engagement) { create(:segment, name: "Family Engagement", parent: edtech) }
    let(:k12) { create(:segment, name: "K-12", parent: edtech) }
    let!(:root_company) { Company.create!(name: "Root Co", company_type: "Product", user: user, industry: edtech) }
    let!(:family_company) { Company.create!(name: "Family Co", company_type: "Product", user: user, industry: family_engagement) }
    let!(:k12_company) { Company.create!(name: "K12 Co", company_type: "Product", user: user, industry: k12) }
    let!(:unrelated_company) { Company.create!(name: "Other Co", company_type: "Product", user: user, industry: create(:industry)) }

    it "matches a top-level industry and all of its segments" do
      expect(Company.in_industry(edtech)).to contain_exactly(root_company, family_company, k12_company)
    end

    it "matches only the segment when a segment is given" do
      expect(Company.in_industry(family_engagement)).to contain_exactly(family_company)
    end
  end
end
