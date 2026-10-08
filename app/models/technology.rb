class Technology < ApplicationRecord
  has_many :opportunity_technologies, dependent: :destroy
  has_many :opportunities, through: :opportunity_technologies

  validates :name, presence: true, uniqueness: true
  validates :category, presence: true

  # Category constants for easier reference
  CATEGORIES = [
    "Backend",
    "Frontend",
    "Database",
    "Testing",
    "DevOps/Infrastructure",
    "API/Integration",
    "AI/LLM",
    "AI Engineering Expectations",
    "AI Tools",
    "Observability",
    "Event/Messaging",
    "Other"
  ].freeze

  AI_CAPABILITIES = [
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
  ].freeze

  AI_EXPECTATIONS = [
    "AI Proficiency",
    "AI Productivity / Velocity",
    "AI Leadership / Mentorship",
    "AI Standards / Adoption",
    "Continuous AI Learning"
  ].freeze

  AI_TOOLS = [
    "Claude Code",
    "Cursor",
    "GitHub Copilot",
    "OpenAI API",
    "Anthropic API",
    "Gemini API"
  ].freeze

  PASTE_ALIASES = {
    "AI-Assisted Development" => [ "AI-assisted coding", "AI-native development", "AI-enabled SDLC", "LLM-assisted development", "daily use of AI coding agents", "AI coding agents" ],
    "AI Coding Agents" => [ "AI coding agents", "coding assistants", "AI pair programming", "agentic coding assistants", "daily use of AI coding agents", "Claude Code", "Cursor", "GitHub Copilot" ],
    "Agentic Workflows" => [ "agentic SDLC", "agent-driven development", "autonomous coding workflows" ],
    "AI Agents / Agentic AI" => [ "AI agents", "autonomous agents", "agentic systems", "AI agent development", "Agentic AI" ],
    "Multi-Agent Orchestration" => [ "multi-agent systems", "agent orchestration", "agent coordination" ],
    "LLM APIs & Integration" => [ "LLM API", "LLM integration", "production LLM integration", "LLM APIs", "OpenAI API", "Anthropic API", "Gemini API" ],
    "Prompt Engineering" => [ "prompt design", "prompt optimization", "prompting strategies" ],
    "Context Engineering" => [ "context management", "context-window management", "context optimization", "context window management" ],
    "Function / Tool Calling" => [ "function calling", "tool use", "tool-using agents" ],
    "Model Context Protocol (MCP)" => [ "MCP", "MCP servers", "MCP tools", "MCP integrations" ],
    "Retrieval-Augmented Generation (RAG)" => [ "RAG", "retrieval pipelines", "retrieval-augmented applications" ],
    "Embeddings & Vector Search" => [ "embeddings", "semantic retrieval", "similarity search", "vector search" ],
    "Vector Databases" => [ "vector databases", "vector stores", "vector DB integration" ],
    "LLM Evaluation & Testing" => [ "LLM evaluation", "evals", "AI output evaluation", "agent testing" ],
    "AI-Powered Product Features" => [ "AI features", "LLM-powered applications", "AI-powered search", "AI product integration" ],
    "AI Workflow Automation" => [ "AI automation", "automated workflows", "AI-driven business processes" ],
    "AI Proficiency" => [ "AI fluency", "AI-native engineer", "advanced AI tool usage" ],
    "AI Productivity / Velocity" => [ "AI leverage", "productivity multiplier", "accelerated development", "increased engineering velocity" ],
    "AI Leadership / Mentorship" => [ "AI champion", "AI engineering leadership", "mentoring AI adoption" ],
    "AI Standards / Adoption" => [ "AI engineering standards", "team adoption", "AI best practices", "AI governance" ],
    "Continuous AI Learning" => [ "staying current with AI tooling", "evaluating emerging AI tools", "recommending new AI capabilities" ]
  }.freeze
end
