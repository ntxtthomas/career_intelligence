require "rails_helper"
require_relative "../../db/migrate/20261008130000_repair_ai_technology_catalog"

RSpec.describe RepairAiTechnologyCatalog do
  let(:user) { create(:user) }

  it "normalizes malformed persisted names, merges joins, and remains idempotent" do
    Technology.seed_ai_catalog!
    opportunity = Opportunity.create!(
      company: Company.create!(name: "Repair Co", company_type: "Product", user: user),
      position_title: "AI Engineer",
      role_type: "software_engineer"
    )

    malformed_technologies = described_class::MALFORMED_NAMES.to_h do |malformed_name, canonical_name|
      technology = Technology.create!(name: malformed_name, category: "AI/LLM")
      OpportunityTechnology.find_or_create_by!(opportunity: opportunity, technology: Technology.find_by!(name: canonical_name))
      OpportunityTechnology.create!(opportunity: opportunity, technology: technology)
      [ malformed_name, technology ]
    end
    company = opportunity.company
    company.update_column(:known_tech_stack, described_class::MALFORMED_NAMES.keys.join(", "))

    migration = described_class.new
    migration.up

    expect(Technology.where(category: "AI/LLM").pluck(:name)).to match_array(Technology::AI_CAPABILITIES)
    expect(Technology.where(category: "AI Engineering Expectations").pluck(:name)).to match_array(Technology::AI_EXPECTATIONS)
    expect(Technology.where(category: "AI Tools").pluck(:name)).to match_array(Technology::AI_TOOLS)
    expect(Technology.where(category: [ "AI/LLM", "AI Engineering Expectations", "AI Tools" ]).count).to eq(27)

    described_class::MALFORMED_NAMES.each do |malformed_name, canonical_name|
      expect(Technology.exists?(malformed_technologies.fetch(malformed_name).id)).to be(false)
      expect(opportunity.technologies.where(name: canonical_name).count).to eq(1)
    end

    expect(company.reload.known_tech_stack.split(", ")).to match_array(described_class::MALFORMED_NAMES.values.uniq)
    expect { migration.up }.not_to change { Technology.where(category: [ "AI/LLM", "AI Engineering Expectations", "AI Tools" ]).count }
  end
end
