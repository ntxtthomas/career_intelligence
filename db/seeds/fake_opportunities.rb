# Usage:
#   bin/rails runner db/seeds/fake_opportunities.rb
#   FAKE_OPPORTUNITIES_COUNT=250 bin/rails runner db/seeds/fake_opportunities.rb
#   SEED_USER_EMAIL=owner@jobtracker.dev bin/rails runner db/seeds/fake_opportunities.rb

count = ENV.fetch("FAKE_OPPORTUNITIES_COUNT", 100).to_i
seed_user_email = ENV.fetch("SEED_USER_EMAIL", "demo@jobtracker.dev")

if count <= 0
  puts "FAKE_OPPORTUNITIES_COUNT must be greater than 0"
  exit(1)
end

user = User.find_by(email: seed_user_email)

unless user
  puts "No user found with email #{seed_user_email.inspect}."
  puts "Create that user first or set SEED_USER_EMAIL to an existing user."
  exit(1)
end

tech_ids = Technology.pluck(:id)
if tech_ids.empty?
  puts "No technologies found. Run bin/rails db:seed first to create technologies."
  exit(1)
end

puts "Generating #{count} fake opportunities for #{user.email}..."

role_types = Opportunity::ROLE_TYPES.keys.freeze
statuses = %w[applied interviewing closed].freeze
sources = %w[linkedin indeed referral company_website staffing_agency].freeze
company_types = %w[Product Consultancy Staffing].freeze

adjectives = %w[
  Agile Bright Catalyst Coastal Delta Elevate Ember First Forge Future Golden Helix
  Horizon Ignite Lattice Metric North Orbit Peak Prime Quantum Rapid Summit True Vector
].freeze

nouns = %w[
  Analytics Cloud Data Dynamics Labs Logic Matrix Networks Platform Robotics Security
  Software Systems Tech Ventures Works
].freeze

company_locations = [
  "Austin, TX",
  "San Francisco, CA",
  "Denver, CO",
  "Seattle, WA",
  "Remote",
  "Boston, MA",
  "Raleigh, NC",
  "Chicago, IL"
].freeze

position_titles_by_role = {
  "software_engineer" => [
    "Backend Engineer",
    "Senior Software Engineer",
    "Platform Engineer",
    "Full Stack Engineer"
  ],
  "sales_engineer" => [
    "Sales Engineer",
    "Senior Sales Engineer",
    "Solutions Consultant",
    "Enterprise Sales Engineer"
  ],
  "solutions_engineer" => [
    "Solutions Engineer",
    "Principal Solutions Engineer",
    "Implementation Engineer",
    "Customer Solutions Architect"
  ],
  "product_manager" => [
    "Product Manager",
    "Senior Product Manager",
    "Technical Product Manager",
    "Platform Product Manager"
  ],
  "support_engineer" => [
    "Technical Support Engineer",
    "Senior Support Engineer",
    "Customer Support Engineer",
    "Production Support Engineer"
  ],
  "success_engineer" => [
    "Customer Success Engineer",
    "Technical Success Manager",
    "Onboarding Engineer",
    "Post-Sales Success Engineer"
  ],
  "other" => [
    "Technical Program Manager",
    "Developer Advocate",
    "Systems Analyst",
    "Technical Consultant"
  ]
}.freeze

def role_metadata_for(role_type)
  case role_type
  when "sales_engineer"
    {
      sales_motion: %w[enterprise mid_market smb].sample,
      customer_persona: %w[operators it_security engineering leadership].sample(2),
      domain_depth: %w[light moderate deep].sample,
      demo_intensity: %w[standard custom heavy].sample,
      pressure_sources: {
        quota_pressure: [ true, false ].sample,
        travel_percent: [ 0, 10, 25, 40 ].sample,
        overtime_expected: [ true, false ].sample,
        deal_urgency: %w[monthly quarterly annual].sample,
        exec_visibility: %w[low medium high].sample
      },
      fit_reasons: %w[prior_customer domain_operator technical_depth communication].sample(2),
      nervous_system_cost: %w[low medium high].sample,
      remote_tolerance: %w[strict flexible hybrid].sample
    }
  when "solutions_engineer"
    {
      solution_scope: %w[single_product multi_product platform].sample,
      customer_size: %w[smb mid_market enterprise].sample,
      implementation_depth: %w[light moderate deep].sample,
      travel_requirement: [ 0, 10, 25, 40 ].sample
    }
  when "product_manager"
    {
      product_stage: %w[0_to_1 growth mature turnaround].sample,
      stakeholder_complexity: %w[low medium high].sample,
      technical_depth_required: %w[low medium high].sample,
      customer_interaction: %w[low medium high].sample
    }
  else
    {}
  end
end

IndustryCatalog.seed!
industries = Industry.where(
  name: [ "Technology", "Cloud Infrastructure", "Developer Tools", "Cybersecurity", "E-commerce", "FinTech", "HealthTech" ],
  parent_id: nil
).to_a

created = 0
company_cache = []

count.times do |i|
  # Reuse companies so the data looks realistic (multiple roles per company).
  company = if company_cache.any? && rand < 0.7
    company_cache.sample
  else
    company_name = "#{adjectives.sample} #{nouns.sample} #{i + 1}"
    company = Company.create!(
      user: user,
      name: company_name,
      industry: industries.sample,
      location: company_locations.sample,
      company_type: company_types.sample,
      size: [ "11-50", "51-200", "201-500", "501-1000", "1001-5000" ].sample
    )
    company_cache << company
    company
  end

  role_type = role_types.sample
  title = position_titles_by_role.fetch(role_type).sample

  opportunity = Opportunity.create!(
    company: company,
    position_title: title,
    application_date: rand(120).days.ago.to_date,
    status: statuses.sample,
    remote: [ true, false ].sample,
    source: sources.sample,
    salary_range: [
      "$95k-$120k",
      "$110k-$140k",
      "$125k-$155k",
      "$140k-$180k",
      "$160k-$200k"
    ].sample,
    role_type: role_type,
    fit_score: rand(40..98) / 10.0,
    trajectory_score: rand(1..10),
    strategic_value: rand(1..10),
    bus_factor: rand(1..5),
    remote_type: %w[remote hybrid onsite].sample,
    risk_level: %w[low medium high].sample,
    role_metadata: role_metadata_for(role_type),
    notes: "Generated seed record ##{i + 1} for pagination/API testing."
  )

  selected_tech_ids = tech_ids.sample(rand(2..6))
  opportunity.technology_ids = selected_tech_ids

  created += 1
end

puts "Created #{created} opportunities for #{user.email}."
puts "Total opportunities for user now: #{user.opportunities.count}"
