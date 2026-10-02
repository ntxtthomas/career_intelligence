namespace :companies do
  desc "Update Real Estate related industries to PropTech"
  task update_proptech_industry: :environment do
    patterns = [
      "Real Estate",
      "Real Estate Technology",
      "Real Estate SaaS"
    ]

    proptech = Industry.find_by!(name: "PropTech", parent_id: nil)

    companies_to_update = Company.where(
      patterns.map { |pattern| "legacy_industry ILIKE ?" }.join(" OR "),
      *patterns.map { |pattern| "%#{pattern}%" }
    ).where("industry_id IS DISTINCT FROM ?", proptech.id)

    count = companies_to_update.count

    if count.zero?
      puts "No companies found with Real Estate related industries."
    else
      puts "Found #{count} #{"company".pluralize(count)} to update:"
      companies_to_update.each do |company|
        puts "  - #{company.name}: '#{company.legacy_industry}' -> 'PropTech'"
      end

      print "\nProceed with update? (y/n): "
      response = STDIN.gets.chomp.downcase

      if response == "y"
        updated = companies_to_update.update_all(industry_id: proptech.id)
        puts "\n✓ Successfully updated #{updated} #{"company".pluralize(updated)} to PropTech"
      else
        puts "\n✗ Update cancelled"
      end
    end
  end
end
