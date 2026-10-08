require "rails_helper"

RSpec.describe TechStackAnalyzer do
  let(:user) { create(:user) }
  let(:company) { Company.create!(name: "AI Taxonomy Co", company_type: "Product", user: user) }
  let(:opportunity) { Opportunity.create!(company: company, position_title: "AI Engineer", role_type: "software_engineer") }

  it "keeps expectation frequency visible by category but excludes it from skill recommendations" do
    expectation = Technology.create!(name: "AI Proficiency", category: "AI Engineering Expectations")
    capability = Technology.create!(name: "AI-Assisted Development", category: "AI/LLM")
    tool = Technology.create!(name: "Claude Code", category: "AI Tools")
    opportunity.technologies = [ expectation, capability, tool ]

    analyzer = described_class.new(Opportunity.where(id: opportunity.id))

    expect(analyzer.analyze_by_category).to include("AI Engineering Expectations" => 1, "AI/LLM" => 1, "AI Tools" => 1)
    expect(analyzer.top_technologies(exclude_categories: [ "AI Engineering Expectations" ]).keys).to contain_exactly("AI-Assisted Development", "Claude Code")
    expect(analyzer.learning_priorities(min_count: 1)).not_to include("AI Proficiency")
    expect(analyzer.learning_insights(limit: 10).map { |insight| insight[:name] }).not_to include("AI Proficiency")
  end
end
