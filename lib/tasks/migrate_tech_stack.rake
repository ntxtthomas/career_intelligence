namespace :opportunities do
  desc "Migrate tech_stack strings to structured technologies"
  task migrate_tech_stack: :environment do
    puts "Starting tech_stack migration..."

    # Mapping of common variations to Technology names
    tech_mappings = {
      "ruby on rails" => "Ruby on Rails",
      "rails" => "Ruby on Rails",
      "ror" => "Ruby on Rails",
      "react" => "React",
      "reactjs" => "React",
      "react.js" => "React",
      "vue" => "Vue",
      "vuejs" => "Vue",
      "vue.js" => "Vue",
      "python" => "Python",
      "graphql" => "GraphQL",
      "postgres" => "PostgreSQL",
      "postgresql" => "PostgreSQL",
      "mysql" => "MySQL",
      "mongodb" => "MongoDB",
      "mongo" => "MongoDB",
      "node" => "Node.js",
      "nodejs" => "Node.js",
      "node.js" => "Node.js",
      "typescript" => "TypeScript",
      "javascript" => "JavaScript",
      "js" => "JavaScript",
      "docker" => "Docker",
      "kubernetes" => "Kubernetes",
      "k8s" => "Kubernetes",
      "aws" => "AWS",
      "tailwind" => "Tailwind",
      "bootstrap" => "Bootstrap",
      "angular" => "Angular",
      "next.js" => "Next.js",
      "nextjs" => "Next.js"
    }

    migrated_count = 0
    skipped_count = 0
    not_found = []

    Opportunity.find_each.with_index do |opportunity, index|
      next if opportunity.tech_stack.blank? || opportunity.tech_stack.downcase.in?([ "n/a", "na", "none" ])

      # Split by comma or semicolon and clean up
      tech_names = opportunity.tech_stack.split(/[,;]/).map(&:strip).reject(&:blank?)

      tech_names.each do |tech_name|
        # Normalize the name
        normalized = tech_name.downcase.strip
        canonical_name = tech_mappings[normalized] || tech_name.titleize

        # Find the technology
        tech = Technology.find_by("LOWER(name) = ?", canonical_name.downcase)

        if tech
          # Create the association if it doesn't exist
          unless opportunity.technologies.include?(tech)
            opportunity.technologies << tech
            puts "  ID #{opportunity.id}: Added '#{tech.name}'"
          end
        else
          # No matching Technology record - flag for manual review
          unless not_found.include?(tech_name)
            not_found << tech_name
          end
          puts "  ID #{opportunity.id}: '#{tech_name}' not found - flagged for manual review"
        end
      end

      migrated_count += 1

      print "." if (index + 1) % 10 == 0
    end

    puts "\n\nMigration completed!"
    puts "Migrated: #{migrated_count} opportunities"
    puts "Technologies not found (flagged for manual review): #{not_found.uniq.join(', ')}" if not_found.any?
    puts "\nNote: Review flagged technologies and create missing Technology records if needed."
  end
end
