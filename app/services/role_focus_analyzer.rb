class RoleFocusAnalyzer
  # Define focus areas for each role type
  ROLE_FOCUS_AREAS = {
    "software_engineer" => [
      { category: "Backend", weight: 0.3 },
      { category: "Frontend", weight: 0.3 },
      { category: "Database", weight: 0.2 },
      { category: "DevOps/Infrastructure", weight: 0.1 },
      { category: "Testing", weight: 0.1 }
    ],
    "sales_engineer" => [
      { name: "Domain Expertise", description: "Deep understanding of customer industry and pain points" },
      { name: "Technical Storytelling", description: "Translate complex technical concepts into business value" },
      { name: "Demo & Presentation Skills", description: "Compelling product demonstrations and customer engagement" },
      { name: "Solution Architecture", description: "Design and articulate technical solutions for customer needs" }
    ],
    "solutions_engineer" => [
      { name: "Integration Expertise", description: "APIs, webhooks, and system integration patterns" },
      { name: "Customer Success Mindset", description: "Implementation planning and technical enablement" },
      { name: "Problem-Solving Under Pressure", description: "Troubleshooting and rapid technical resolution" },
      { name: "Documentation & Training", description: "Creating clear technical guides and customer training" }
    ],
    "product_manager" => [
      { name: "User Research & Insights", description: "Understanding customer needs and market trends" },
      { name: "Data-Driven Decision Making", description: "Analytics, metrics, and quantitative analysis" },
      { name: "Roadmap & Prioritization", description: "Strategic planning and stakeholder alignment" },
      { name: "Cross-Functional Leadership", description: "Collaboration with engineering, design, and business teams" }
    ],
    "support_engineer" => [
      { name: "Troubleshooting Methodology", description: "Systematic debugging and root cause analysis" },
      { name: "Customer Communication", description: "Clear technical explanations and empathy" },
      { name: "Product Knowledge", description: "Deep understanding of product functionality and architecture" },
      { name: "Ticket Management", description: "Prioritization, escalation, and workflow efficiency" }
    ],
    "success_engineer" => [
      { name: "Relationship Building", description: "Trust development and strategic account management" },
      { name: "Product Adoption Strategy", description: "Driving user engagement and feature utilization" },
      { name: "Proactive Problem Prevention", description: "Health monitoring and early intervention" },
      { name: "Business Outcome Alignment", description: "Connecting product usage to customer success metrics" }
    ],
    "other" => [
      { name: "Adaptability", description: "Flexibility across various technical and business contexts" },
      { name: "Learning Agility", description: "Quickly acquiring new skills and domain knowledge" },
      { name: "Communication Skills", description: "Clear articulation across technical and non-technical audiences" },
      { name: "Initiative & Ownership", description: "Self-direction and proactive problem-solving" }
    ]
  }.freeze

  def initialize(opportunities)
    @opportunities = opportunities
  end

  # Generate focus insights based on role type distribution
  def generate_insights(limit: 4)
    role_distribution = calculate_role_distribution
    return [] if role_distribution.empty?

    # Find the most common role type
    primary_role = role_distribution.max_by { |_role, count| count }&.first
    return [] unless primary_role

    # Get focus areas for the primary role
    focus_areas = ROLE_FOCUS_AREAS[primary_role] || []

    if primary_role == "software_engineer"
      # For software engineers, analyze actual technologies
      generate_tech_insights(limit)
    else
      # For other roles, return predefined focus areas
      focus_areas.first(limit).map.with_index do |area, index|
        {
          name: area[:name],
          insight: area[:description],
          category: primary_role.titleize,
          priority: limit - index,
          role_type: primary_role
        }
      end
    end
  end

  # Generate insights for all roles with opportunities
  def generate_all_role_insights(limit_per_role: 3)
    role_distribution = calculate_role_distribution
    return {} if role_distribution.empty?

    insights_by_role = {}

    role_distribution.each do |role_type, count|
      next if count.zero?

      focus_areas = ROLE_FOCUS_AREAS[role_type] || []

      if role_type == "software_engineer"
        # For software engineers, analyze actual technologies
        role_opportunities = @opportunities.where(role_type: role_type)
        insights_by_role[role_type] = {
          count: count,
          label: Opportunity::ROLE_TYPES[role_type],
          insights: generate_tech_insights_for_opportunities(role_opportunities, limit_per_role)
        }
      else
        # For other roles, return predefined focus areas
        insights_by_role[role_type] = {
          count: count,
          label: Opportunity::ROLE_TYPES[role_type],
          insights: focus_areas.first(limit_per_role).map.with_index do |area, index|
            {
              name: area[:name],
              insight: area[:description],
              priority: limit_per_role - index,
              role_type: role_type
            }
          end
        }
      end
    end

    insights_by_role
  end

  private

  def calculate_role_distribution
    @opportunities.group(:role_type).count.sort_by { |_role, count| -count }.to_h
  end

  def generate_tech_insights(limit)
    generate_tech_insights_for_opportunities(@opportunities, limit)
  end

  def generate_tech_insights_for_opportunities(opportunities, limit)
    opportunities_with_tech = opportunities.joins(:technologies).distinct
    return [] if opportunities_with_tech.empty?

    analyzer = TechStackAnalyzer.new(opportunities_with_tech)
    total_opps = opportunities_with_tech.count

    tech_data = analyzer.top_technologies(limit: 20, exclude_categories: [ "AI Engineering Expectations" ])
    insights = []

    tech_data.each do |tech_name, count|
      percentage = (count.to_f / total_opps * 100).round

      tech = Technology.find_by(name: tech_name)
      next unless tech

      insight = generate_tech_insight(tech_name, tech.category, count, percentage, total_opps)

      insights << {
        name: tech_name,
        count: count,
        percentage: percentage,
        insight: insight,
        category: tech.category,
        priority: calculate_priority(percentage, count),
        role_type: "software_engineer"
      }
    end

    # Sort by priority score
    insights.sort_by { |i| -i[:priority] }.first(limit)
  end

  def generate_tech_insight(tech_name, category, count, percentage, total_opps)
    case category
    when "Backend"
      if percentage >= 80
        "Core skill - appears in #{count}/#{total_opps} jobs you're tracking"
      elsif percentage >= 50
        "High demand - #{percentage}% of opportunities require this"
      else
        "Growing requirement - consider learning for #{count} roles"
      end
    when "Frontend"
      if percentage >= 70
        "Essential frontend skill - needed for #{percentage}% of roles"
      elsif percentage >= 40
        "Common pairing - appears in #{count} opportunities"
      else
        "Emerging in #{count} roles - could expand your options"
      end
    when "Database"
      if percentage >= 60
        "Critical data skill - #{percentage}% of jobs need this"
      else
        "Frequently mentioned database - #{count} opportunities"
      end
    when "Testing"
      "Quality focus - #{count} roles emphasize testing with this"
    when "DevOps/Infrastructure"
      if percentage >= 30
        "Infrastructure skill - needed in #{percentage}% of jobs"
      else
        "DevOps competency for #{count} positions"
      end
    else
      "Required in #{percentage}% of opportunities"
    end
  end

  def calculate_priority(percentage, count)
    # Weight both percentage and absolute count
    (percentage * 0.7) + (count * 0.3)
  end
end
