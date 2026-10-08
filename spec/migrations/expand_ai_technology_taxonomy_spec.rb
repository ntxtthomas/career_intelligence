require "rails_helper"
require_relative "../../db/migrate/20261008120000_expand_ai_technology_taxonomy"

RSpec.describe ExpandAiTechnologyTaxonomy do
  let(:user) { create(:user) }
  let(:company) do
    Company.create!(name: "Taxonomy Co", company_type: "Product", user: user, known_tech_stack: "Agentic AI, LLM API, MCP, Prompt Engineering, RAG, Vector Databases")
  end
  let(:opportunity) do
    Opportunity.create!(company: company, position_title: "AI Engineer", role_type: "software_engineer")
  end

  it "renames legacy records in place and preserves their opportunity associations" do
    legacy_names = [ "Agentic AI", "LLM API", "MCP", "Prompt Engineering", "RAG", "Vector Databases" ]
    legacy_technologies = legacy_names.index_with { |name| Technology.create!(name: name, category: "AI/LLM") }
    legacy_technologies.each_value do |technology|
      OpportunityTechnology.create!(opportunity: opportunity, technology: technology)
    end

    described_class.new.up

    expected_names = {
      "Agentic AI" => "AI Agents / Agentic AI",
      "LLM API" => "LLM APIs & Integration",
      "MCP" => "Model Context Protocol (MCP)",
      "Prompt Engineering" => "Prompt Engineering",
      "RAG" => "Retrieval-Augmented Generation (RAG)",
      "Vector Databases" => "Vector Databases"
    }

    expected_names.each do |legacy_name, canonical_name|
      technology = Technology.find(legacy_technologies.fetch(legacy_name).id)
      expect(technology.name).to eq(canonical_name)
      expect(technology.category).to eq("AI/LLM")
      expect(technology.opportunities).to include(opportunity)
    end

    expect(company.reload.known_tech_stack).to eq("AI Agents / Agentic AI, LLM APIs & Integration, Model Context Protocol (MCP), Prompt Engineering, Retrieval-Augmented Generation (RAG), Vector Databases")
  end

  it "merges into an existing canonical row without duplicating opportunity joins" do
    opportunity
    legacy = Technology.create!(name: "Agentic AI", category: "AI/LLM")
    canonical = Technology.create!(name: "AI Agents / Agentic AI", category: "AI/LLM")
    OpportunityTechnology.create!(opportunity: opportunity, technology: legacy)
    OpportunityTechnology.create!(opportunity: opportunity, technology: canonical)

    described_class.new.up

    expect(Technology.exists?(legacy.id)).to be(false)
    expect(Technology.find(canonical.id).opportunities.where(id: opportunity.id).count).to eq(1)
    expect(OpportunityTechnology.where(opportunity: opportunity, technology: canonical).count).to eq(1)
  end

  it "creates the new capability, expectation, tool, .NET, and Svelte records" do
    described_class.new.up

    expect(Technology.where(category: "AI/LLM").pluck(:name)).to match_array(Technology::AI_CAPABILITIES)
    expect(Technology.where(category: "AI Engineering Expectations").pluck(:name)).to match_array(Technology::AI_EXPECTATIONS)
    expect(Technology.where(category: "AI Tools").pluck(:name)).to match_array(Technology::AI_TOOLS)
    expect(Technology.find_by!(name: ".NET").category).to eq("Backend")
    expect(Technology.find_by!(name: "Svelte").category).to eq("Frontend")
  end
end
