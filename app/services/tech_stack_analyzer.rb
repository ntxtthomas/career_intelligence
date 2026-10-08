class TechStackAnalyzer
  def self.analyze_combinations(opportunities = Opportunity.all)
    new(opportunities).analyze_combinations
  end

  def self.analyze_by_category(opportunities = Opportunity.all)
    new(opportunities).analyze_by_category
  end

  def initialize(opportunities)
    @opportunities = opportunities.includes(:technologies)
  end

  # Returns hash of tech combinations with their counts
  # e.g., { "Ruby on Rails, React, PostgreSQL" => 8, ... }
  def analyze_combinations
    combination_counts = Hash.new(0)

    @opportunities.each do |opp|
      next if opp.technologies.empty?

      # Sort technologies by category then name for consistent grouping
      tech_names = opp.technologies
                      .order(:category, :name)
                      .pluck(:name)
                      .join(", ")

      combination_counts[tech_names] += 1
    end

    # Sort by count descending
    combination_counts.sort_by { |_combo, count| -count }.to_h
  end

  # Returns simplified tech combinations showing only Backend + Frontend
  # e.g., { "Ruby on Rails + React" => 8, "Python + Vue" => 5, ... }
  # Excludes intermediate technologies (JavaScript, Tailwind, etc.)
  def analyze_main_stack_combinations
    combination_counts = Hash.new(0)

    # Main framework technologies to track
    backend_frameworks = [ "Ruby on Rails", "Python", "Django", "Node.js", "Express", "FastAPI" ]
    frontend_frameworks = [ "React", "Vue", "Angular", "Stimulus", "Hotwire" ]

    @opportunities.each do |opp|
      next if opp.technologies.empty?

      tech_names = opp.technologies.pluck(:name)

      # Find which backend framework is used
      backend = backend_frameworks.find { |fw| tech_names.include?(fw) }

      # Find which frontend framework is used
      frontend = frontend_frameworks.find { |fw| tech_names.include?(fw) }

      # Build combo key
      combo_parts = []
      combo_parts << backend if backend
      combo_parts << frontend if frontend

      next if combo_parts.empty?

      combo_key = combo_parts.join(" + ")
      combination_counts[combo_key] += 1
    end

    # Sort by count descending
    combination_counts.sort_by { |_combo, count| -count }.to_h
  end

  # Returns count by category
  # e.g., { "Backend" => 20, "Frontend" => 18, ... }
  def analyze_by_category
    category_counts = Hash.new(0)

    Technology::CATEGORIES.each do |category|
      count = OpportunityTechnology
                .joins(:technology)
                .where(technologies: { category: category })
                .where(opportunity_id: @opportunities.pluck(:id))
                .distinct
                .count(:opportunity_id)

      category_counts[category] = count if count > 0
    end

    category_counts
  end

  # Returns most common individual technologies
  # e.g., { "Ruby on Rails" => 20, "React" => 18, ... }
  def top_technologies(limit: 10, exclude_categories: [])
    tech_counts = Hash.new(0)

    technologies = Technology
      .joins(:opportunity_technologies)
      .where(opportunity_technologies: { opportunity_id: @opportunities.pluck(:id) })

    technologies = technologies.where.not(category: exclude_categories) if exclude_categories.any?

    technologies
      .group(:name, :category)
      .count
      .sort_by { |_tech, count| -count }
      .first(limit)
      .to_h
      .transform_keys { |key| key.first } # Extract just the name from [name, category] tuple
  end

  # Analyze what technologies are commonly paired together
  # Returns array of hashes: [{ tech: "React", paired_with: { "Ruby on Rails" => 15, "Node.js" => 5 } }, ...]
  def analyze_pairings(technology_name)
    tech = Technology.find_by(name: technology_name)
    return {} unless tech

    # Find all opportunities with this technology
    opportunity_ids = tech.opportunity_technologies.pluck(:opportunity_id)

    # Count other technologies in those opportunities
    pairing_counts = Technology
      .joins(:opportunity_technologies)
      .where(opportunity_technologies: { opportunity_id: opportunity_ids })
      .where.not(id: tech.id)
      .group(:name)
      .count
      .sort_by { |_name, count| -count }
      .to_h

    {
      tech: technology_name,
      total_opportunities: opportunity_ids.count,
      paired_with: pairing_counts
    }
  end

  # Identify skill gaps - technologies appearing in many jobs but user may want to learn
  def learning_priorities(min_count: 3)
    top_technologies(limit: 20, exclude_categories: [ "AI Engineering Expectations" ])
      .select { |_tech, count| count >= min_count }
      .keys
  end

  # Generate actionable learning insights with context
  # Returns array of hashes with technology name, count, percentage, and insight message
  def learning_insights(limit: 5)
    total_opps = @opportunities.count
    return [] if total_opps.zero?

    tech_data = top_technologies(limit: 20, exclude_categories: [ "AI Engineering Expectations" ])
    insights = []

    tech_data.each do |tech_name, count|
      percentage = (count.to_f / total_opps * 100).round
      next if percentage < 15 # Only show technologies in 15%+ of jobs

      # Generate contextual insight
      insight = generate_insight(tech_name, count, percentage, total_opps)

      insights << {
        name: tech_name,
        count: count,
        percentage: percentage,
        insight: insight,
        priority: calculate_priority(percentage, count)
      }
    end

    # Sort by priority score (high percentage + high absolute count)
    insights.sort_by { |i| -i[:priority] }.first(limit)
  end

  private

  def generate_insight(tech_name, count, percentage, total_opps)
    tech = Technology.find_by(name: tech_name)
    return "Required in #{percentage}% of opportunities" unless tech

    case tech.category
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
        "Infrastructure skill in high demand - #{percentage}% of roles"
      else
        "DevOps requirement for #{count} positions"
      end
    when "API/Integration"
      "Integration expertise - needed in #{count} opportunities"
    else
      "Required in #{percentage}% of opportunities (#{count} jobs)"
    end
  end

  def calculate_priority(percentage, count)
    # Priority = weighted combination of percentage and absolute count
    # Higher weight on percentage to prioritize broadly useful skills
    (percentage * 0.7) + (count * 0.3)
  end
end
