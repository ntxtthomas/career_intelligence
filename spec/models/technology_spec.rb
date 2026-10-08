require "rails_helper"

RSpec.describe Technology, type: :model do
  it "defines the requested canonical AI categories" do
    expect(described_class::AI_CAPABILITIES.size).to eq(16)
    expect(described_class::AI_EXPECTATIONS.size).to eq(5)
    expect(described_class::AI_TOOLS.size).to eq(6)
    expect(described_class::CATEGORIES).to include("AI/LLM", "AI Engineering Expectations", "AI Tools")
  end

  it "keeps each AI classification group distinct" do
    groups = [ described_class::AI_CAPABILITIES, described_class::AI_EXPECTATIONS, described_class::AI_TOOLS ]

    expect(groups.flatten.uniq.size).to eq(groups.sum(&:size))
  end

  it "maps aliases only to known canonical entries" do
    known_names = described_class::AI_CAPABILITIES + described_class::AI_EXPECTATIONS + described_class::AI_TOOLS

    expect(described_class::PASTE_ALIASES.keys - known_names).to be_empty
  end

  it "does not infer named tools from generic capabilities" do
    expect(described_class::PASTE_ALIASES.fetch("LLM APIs & Integration")).not_to include("Claude Code", "Cursor", "GitHub Copilot")
    expect(described_class::PASTE_ALIASES.fetch("AI-Powered Product Features")).not_to include("RAG", "Vector Databases", "MCP")
  end

  it "maps explicit development tool names only to their specific capability" do
    expect(described_class::PASTE_ALIASES.fetch("AI Coding Agents")).to include("Claude Code", "Cursor", "GitHub Copilot")
    expect(described_class::PASTE_ALIASES.fetch("AI-Assisted Development")).to include("AI coding agents")
  end

  it "seeds exactly 27 AI taxonomy records idempotently" do
    2.times { described_class.seed_ai_catalog! }

    described_class::AI_CATALOG.each do |category, expected_names|
      actual_names = described_class.where(category: category).pluck(:name)

      expect(actual_names).to match_array(expected_names)
      expect(actual_names.uniq.size).to eq(expected_names.size)
    end

    expect(described_class.where(category: described_class::AI_CATALOG.keys).count).to eq(27)
  end
end
