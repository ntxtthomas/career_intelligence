class RepairAiTechnologyCatalog < ActiveRecord::Migration[8.0]
  MALFORMED_NAMES = {
    "AI-Assisted" => "AI-Assisted Development",
    "Development" => "AI-Assisted Development",
    'Embeddings \\& Vector Search' => "Embeddings & Vector Search",
    'LLM APIs \\& Integration' => "LLM APIs & Integration",
    'LLM Evaluation \\& Testing' => "LLM Evaluation & Testing",
    'Model Context Protocol \\(MCP\\)' => "Model Context Protocol (MCP)",
    'Retrieval-Augmented Generation \\(RAG\\)' => "Retrieval-Augmented Generation (RAG)"
  }.freeze

  EXPECTED_CATALOG = {
    "AI/LLM" => [
      "AI-Assisted Development", "AI Coding Agents", "Agentic Workflows", "AI Agents / Agentic AI",
      "Multi-Agent Orchestration", "LLM APIs & Integration", "Prompt Engineering", "Context Engineering",
      "Function / Tool Calling", "Model Context Protocol (MCP)", "Retrieval-Augmented Generation (RAG)",
      "Embeddings & Vector Search", "Vector Databases", "LLM Evaluation & Testing",
      "AI-Powered Product Features", "AI Workflow Automation"
    ],
    "AI Engineering Expectations" => [
      "AI Proficiency", "AI Productivity / Velocity", "AI Leadership / Mentorship",
      "AI Standards / Adoption", "Continuous AI Learning"
    ],
    "AI Tools" => [ "Claude Code", "Cursor", "GitHub Copilot", "OpenAI API", "Anthropic API", "Gemini API" ]
  }.freeze

  def up
    MALFORMED_NAMES.each { |source_name, canonical_name| merge_or_rename(source_name, canonical_name) }
    normalize_company_technology_lists
    verify_catalog
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def merge_or_rename(source_name, canonical_name)
    source = Technology.find_by(name: source_name, category: "AI/LLM")
    return unless source

    target = Technology.find_by(name: canonical_name)
    unless target
      source.update!(name: canonical_name, category: "AI/LLM")
      return
    end

    target.update!(category: "AI/LLM") unless target.category == "AI/LLM"
    source.opportunity_technologies.find_each do |association|
      OpportunityTechnology.find_or_create_by!(opportunity_id: association.opportunity_id, technology_id: target.id)
    end
    source.destroy!
  end

  def normalize_company_technology_lists
    Company.where.not(known_tech_stack: [ nil, "" ]).find_each do |company|
      names = company.known_tech_stack.split(",").map(&:strip)
      has_split_ai_assisted_name = names.include?("AI-Assisted")
      normalized_names = names.filter_map do |name|
        if name == "Development"
          next if has_split_ai_assisted_name

          name
        else
          MALFORMED_NAMES.fetch(name, name)
        end
      end.uniq
      next if normalized_names == names

      company.update_column(:known_tech_stack, normalized_names.join(", "))
    end
  end

  def verify_catalog
    mismatches = EXPECTED_CATALOG.filter_map do |category, expected_names|
      actual_names = Technology.where(category: category).order(:name).pluck(:name)
      next if actual_names.sort == expected_names.sort

      "#{category}: missing=#{(expected_names - actual_names).inspect}, unexpected=#{(actual_names - expected_names).inspect}"
    end

    return if mismatches.empty? && EXPECTED_CATALOG.values.flatten.uniq.size == 27

    raise ActiveRecord::MigrationError, "AI technology catalog integrity check failed: #{mismatches.join('; ')}"
  end
end
