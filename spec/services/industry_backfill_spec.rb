require "rails_helper"

RSpec.describe IndustryBackfill do
  let(:user) { create(:user) }

  def company_with(legacy_industry, **attrs)
    company = Company.create!(name: "Co #{SecureRandom.hex(4)}", company_type: "Product", user: user, **attrs)
    company.update_column(:legacy_industry, legacy_industry)
    company
  end

  it "maps legacy spellings onto one canonical industry, case-insensitively" do
    companies = [ "FinTech", "Fintech", "  fintech " ].map { |value| company_with(value) }

    described_class.call

    expect(companies.map { |company| company.reload.industry.name }.uniq).to eq([ "FinTech" ])
  end

  it "applies the agreed merges" do
    expectations = {
      "Construction Tech" => "ConstructionTech",
      "Contractor Tech" => "ConstructionTech",
      "Education" => "EdTech",
      "E-Learning" => "EdTech",
      "Healthtech" => "HealthTech",
      "Non-Profit Church" => "Religious/Community",
      "Non-Profit Training" => "EdTech",
      "Recruiter" => "Staffing",
      "Technical Staffing" => "Staffing",
      "SaaS" => "Technology",
      "Software Development" => "Technology",
      "Technology Consulting" => "Technology"
    }
    companies = expectations.keys.index_with { |value| company_with(value) }

    described_class.call

    expectations.each do |legacy, canonical|
      expect(companies[legacy].reload.industry.name).to eq(canonical), "expected #{legacy.inspect} to map to #{canonical}"
    end
  end

  it "discards 'Something' and reports unrecognized values without touching them" do
    discarded = company_with("Something")
    unknown = company_with("Widgets")

    report = described_class.call

    expect(discarded.reload.industry).to be_nil
    expect(unknown.reload.industry).to be_nil
    expect(unknown.legacy_industry).to eq("Widgets")
    expect(report).to include(dropped: 1)
    expect(report[:unmapped]).to eq("Widgets" => 1)
  end

  it "skips companies without a legacy industry" do
    company = company_with(nil)

    expect(described_class.call).to include(updated: 0)
    expect(company.reload.industry).to be_nil
  end

  it "is idempotent and never overwrites an industry chosen since" do
    IndustryCatalog.seed!
    chosen = Industry.find_by!(name: "Family Engagement")
    company = company_with("EdTech", industry: chosen)

    first = described_class.call
    second = described_class.call

    expect(first).to include(updated: 0)
    expect(second).to include(updated: 0)
    expect(company.reload.industry).to eq(chosen)
  end

  it "seeds the EdTech segments under EdTech" do
    described_class.call

    edtech = Industry.find_by!(name: "EdTech", parent_id: nil)
    expect(edtech.children.pluck(:name)).to include("Early Childhood Development", "Family Engagement", "K-12", "Higher Ed", "Homeschooling")
  end
end
