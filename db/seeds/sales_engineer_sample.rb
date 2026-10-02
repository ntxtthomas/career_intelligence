# Sample Sales Engineer Opportunity Seed
# Run with: rails runner db/seeds/sales_engineer_sample.rb

puts "Creating sample Sales Engineer opportunity..."

IndustryCatalog.seed!

company = Company.find_or_create_by!(name: "PropertyWare (Sample)") do |c|
  c.industry = Industry.find_by!(name: "PropTech", parent_id: nil)
  c.location = "San Diego, CA"
  c.website = "https://propertyware.com"
  c.company_type = "Product"
  c.size = "201-500"
end

opportunity = Opportunity.create!(
  company: company,
  position_title: "Sales Engineer - Enterprise",
  application_date: Date.today,
  status: "submitted",
  remote: true,
  salary_range: "$120,000-$160,000",
  source: "linkedin",
  role_type: "sales_engineer",
  role_metadata: {
    # Sales Motion
    sales_motion: "enterprise",
    deal_type: "both",
    acv_range: "$50k-$500k",
    sales_cycle_length: "3-6 months",
    quota_type: "influence",

    # Customer & Domain
    customer_persona: [ "operators", "it_security" ],
    domain_depth: "deep",

    # Technical & Demo
    demo_intensity: "custom",
    technical_depth: [ "integrations", "apis", "config" ],

    # Pressure Sources
    pressure_sources: {
      quota_pressure: true,
      travel_percent: 25,
      overtime_expected: true,
      deal_urgency: "quarterly",
      exec_visibility: "high"
    },

    # Fit & Culture
    fit_reasons: [ "prior_customer", "domain_operator" ],
    nervous_system_cost: "medium",
    energy_type: "presenting",
    remote_tolerance: "flexible"
  },
  notes: <<~NOTES
    Strong fit due to:
    - Former PropertyWare customer and implementer
    - Deep domain knowledge in property management
    - Experience with integrations and APIs

    Concerns:
    - Quota pressure and travel requirements
    - Overtime expectations during quarter-end
  NOTES
)

puts "✓ Created Sales Engineer opportunity: #{opportunity.position_title}"
puts "  Company: #{opportunity.company.name}"
puts "  Sales Motion: #{opportunity.sales_motion_summary}"
puts "  Customer Persona: #{opportunity.customer_persona_summary}"
puts "  Pressure: #{opportunity.pressure_summary}"
puts "\nView at: /opportunities/#{opportunity.id}"
