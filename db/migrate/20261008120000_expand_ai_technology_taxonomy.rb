class ExpandAiTechnologyTaxonomy < ActiveRecord::Migration[8.0]
  RENAMES = {
    "Agentic AI" => "AI Agents / Agentic AI",
    "LLM API" => "LLM APIs & Integration",
    "MCP" => "Model Context Protocol (MCP)",
    "RAG" => "Retrieval-Augmented Generation (RAG)"
  }.freeze

  KNOWN_STACK_RENAMES = RENAMES.merge(
    "Prompt Engineering" => "Prompt Engineering",
    "Vector Databases" => "Vector Databases"
  ).freeze

  TECHNOLOGIES_BY_CATEGORY = {
    "Backend" => [ ".NET" ],
    "Frontend" => [ "Svelte" ],
    "AI/LLM" => [
      "AI-Assisted Development",
      "AI Coding Agents",
      "Agentic Workflows",
      "AI Agents / Agentic AI",
      "Multi-Agent Orchestration",
      "LLM APIs & Integration",
      "Prompt Engineering",
      "Context Engineering",
      "Function / Tool Calling",
      "Model Context Protocol (MCP)",
      "Retrieval-Augmented Generation (RAG)",
      "Embeddings & Vector Search",
      "Vector Databases",
      "LLM Evaluation & Testing",
      "AI-Powered Product Features",
      "AI Workflow Automation"
    ],
    "AI Engineering Expectations" => [
      "AI Proficiency",
      "AI Productivity / Velocity",
      "AI Leadership / Mentorship",
      "AI Standards / Adoption",
      "Continuous AI Learning"
    ],
    "AI Tools" => [ "Claude Code", "Cursor", "GitHub Copilot", "OpenAI API", "Anthropic API", "Gemini API" ]
  }.freeze

  def up
    RENAMES.each { |legacy_name, canonical_name| rename_or_merge(legacy_name, canonical_name) }

    KNOWN_STACK_RENAMES.each do |legacy_name, canonical_name|
      Company.where.not(known_tech_stack: [ nil, "" ]).find_each do |company|
        names = company.known_tech_stack.split(",").map(&:strip)
        next unless names.include?(legacy_name)

        canonical_names = names.map { |name| name == legacy_name ? canonical_name : name }.uniq
        company.update_column(:known_tech_stack, canonical_names.join(", "))
      end
    end

    TECHNOLOGIES_BY_CATEGORY.each do |category, names|
      names.each do |name|
        technology = Technology.find_or_initialize_by(name: name)
        technology.category = category
        technology.save! if technology.new_record? || technology.category_changed?
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def rename_or_merge(legacy_name, canonical_name)
    legacy = Technology.find_by(name: legacy_name)
    return unless legacy

    canonical = Technology.find_by(name: canonical_name)
    unless canonical
      legacy.update!(name: canonical_name, category: "AI/LLM")
      return
    end

    legacy.opportunity_technologies.find_each do |association|
      OpportunityTechnology.find_or_create_by!(opportunity_id: association.opportunity_id, technology_id: canonical.id)
    end
    legacy.destroy!
  end
end
