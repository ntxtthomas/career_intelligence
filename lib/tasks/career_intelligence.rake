namespace :career_intelligence do
  desc "Backfill domain_match on existing opportunities from company industry"
  task backfill_domain_match: :environment do
    updated = 0
    skipped = 0

    Opportunity.where(domain_match: "unknown").find_each do |opportunity|
      suggested = opportunity.company&.suggested_domain_match
      if suggested.nil?
        skipped += 1
        next
      end

      opportunity.update_column(:domain_match, suggested)
      updated += 1
    end

    puts "Backfilled #{updated} opportunities. Left unknown (no industry match): #{skipped}."
  end
end
