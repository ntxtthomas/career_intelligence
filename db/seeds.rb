# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# =============================================================================
# Users
# =============================================================================
puts "Seeding users..."

owner = User.find_or_create_by!(email: ENV.fetch("OWNER_EMAIL", "owner@jobtracker.dev")) do |u|
  u.password = ENV.fetch("OWNER_PASSWORD", "changeme123")
  u.demo = false
  puts "  Created owner user: #{u.email}"
end

demo_user = User.find_or_create_by!(email: "demo@jobtracker.dev") do |u|
  u.password = SecureRandom.hex(32)
  u.demo = true
  puts "  Created demo user: #{u.email}"
end

puts "Users seeded! (Owner: #{owner.email}, Demo: #{demo_user.email})"

# Seed Technologies
technologies_data = {
  "Backend" => [
    "Ruby on Rails",
    "Python",
    "Django",
    "Flask",
    "Node.js",
    "Express",
    "Java",
    "Spring Boot",
    "PHP",
    "Laravel",
    ".NET",
    "C#",
    "Go",
    "Elixir",
    "Phoenix"
  ],
  "Frontend" => [
    "React",
    "Vue",
    "Angular",
    "JavaScript",
    "TypeScript",
    "Tailwind",
    "Bootstrap",
    "Foundation",
    "Stimulus",
    "Hotwire",
    "Turbo",
    "Next.js",
    "Nuxt.js",
    "Svelte",
    "HTML/CSS"
  ],
  "Database" => [
    "PostgreSQL",
    "MySQL",
    "MongoDB",
    "Redis",
    "SQLite",
    "MariaDB",
    "Elasticsearch",
    "Cassandra",
    "DynamoDB",
    "Oracle"
  ],
  "Testing" => [
    "RSpec",
    "Jest",
    "Minitest",
    "Capybara",
    "Cypress",
    "Selenium",
    "Mocha",
    "Chai",
    "PyTest",
    "JUnit"
  ],
  "DevOps/Infrastructure" => [
    "Docker",
    "Kubernetes",
    "Jenkins",
    "CI/CD",
    "AWS",
    "AWS RDS",
    "AWS S3",
    "AWS SES",
    "AWS Lambda",
    "Azure",
    "Google Cloud",
    "Heroku",
    "Terraform",
    "Ansible",
    "GitHub Actions",
    "CircleCI"
  ],
  "API/Integration" => [
    "RESTful APIs",
    "GraphQL",
    "gRPC",
    "LLM API Integration",
    "OpenAI API",
    "Stripe API",
    "Twilio",
    "SendGrid",
    "Webhooks"
  ]
}

puts "Seeding technologies..."

technologies_data.each do |category, tech_names|
  tech_names.each do |name|
    Technology.find_or_create_by!(name: name) do |tech|
      tech.category = category
      puts "  Created: #{name} (#{category})"
    end
  end
end

puts "Technology seeding completed!"
puts "Total technologies: #{Technology.count}"

# =============================================================================
# Demo Data (associated with demo user)
# =============================================================================
puts "\nSeeding demo data..."

# Helper to find technologies by name
def find_techs(*names)
  Technology.where(name: names)
end

# --- Demo Companies ---
acme = Company.find_or_create_by!(name: "Acme Cloud Solutions", user: demo_user) do |c|
  c.industry = "Cloud Infrastructure"
  c.location = "Austin, TX"
  c.company_type = "Product"
  c.size = "501-1000"
  c.primary_product = "Cloud orchestration platform"
  c.funding_stage = "Series C"
  puts "  Created demo company: #{c.name}"
end

brightpath = Company.find_or_create_by!(name: "BrightPath Analytics", user: demo_user) do |c|
  c.industry = "Business Intelligence"
  c.location = "Remote"
  c.company_type = "Product"
  c.size = "51-200"
  c.primary_product = "Self-service BI dashboard"
  c.funding_stage = "Series B"
  puts "  Created demo company: #{c.name}"
end

nextstep = Company.find_or_create_by!(name: "NextStep Consulting", user: demo_user) do |c|
  c.industry = "Technology Consulting"
  c.location = "Denver, CO"
  c.company_type = "Consultancy"
  c.size = "201-500"
  puts "  Created demo company: #{c.name}"
end

corestack = Company.find_or_create_by!(name: "CoreStack Technologies", user: demo_user) do |c|
  c.industry = "DevOps / Platform Engineering"
  c.location = "San Francisco, CA"
  c.company_type = "Product"
  c.size = "1001-5000"
  c.primary_product = "Internal developer platform"
  c.funding_stage = "Series D"
  puts "  Created demo company: #{c.name}"
end

talentbridge = Company.find_or_create_by!(name: "TalentBridge Staffing", user: demo_user) do |c|
  c.industry = "Technical Staffing"
  c.location = "Dallas, TX"
  c.company_type = "Staffing"
  c.size = "51-200"
  puts "  Created demo company: #{c.name}"
end

# --- Demo Contacts ---
Contact.find_or_create_by!(name: "Sarah Chen", company: acme) do |c|
  c.title = "Engineering Manager"
  c.email = "sarah.chen@example.com"
  c.linkedin = "https://linkedin.com/in/example-sarahchen"
  puts "  Created demo contact: #{c.name}"
end

Contact.find_or_create_by!(name: "James Rivera", company: acme) do |c|
  c.title = "Senior Recruiter"
  c.email = "james.r@example.com"
  puts "  Created demo contact: #{c.name}"
end

Contact.find_or_create_by!(name: "Priya Patel", company: brightpath) do |c|
  c.title = "VP of Engineering"
  c.email = "priya.p@example.com"
  puts "  Created demo contact: #{c.name}"
end

Contact.find_or_create_by!(name: "Marcus Thompson", company: corestack) do |c|
  c.title = "Staff Engineer"
  c.email = "marcus.t@example.com"
  puts "  Created demo contact: #{c.name}"
end

Contact.find_or_create_by!(name: "Lisa Kim", company: talentbridge) do |c|
  c.title = "Technical Recruiter"
  c.email = "lisa.kim@example.com"
  c.phone = "555-0142"
  puts "  Created demo contact: #{c.name}"
end

# --- Demo Opportunities ---
opp_acme = Opportunity.find_or_create_by!(company: acme, position_title: "Senior Software Engineer") do |o|
  o.application_date = 5.days.ago.to_date
  o.status = "interviewing"
  o.remote = true
  o.salary_range = "$140,000 - $175,000"
  o.source = "linkedin"
  o.role_type = "software_engineer"
  o.notes = "Strong match — cloud-native stack aligns well with background."
  puts "  Created demo opportunity: #{o.position_title} @ #{acme.name}"
end
opp_acme.technologies = find_techs("Ruby on Rails", "PostgreSQL", "Docker", "AWS", "Redis")

opp_bright = Opportunity.find_or_create_by!(company: brightpath, position_title: "Full Stack Developer") do |o|
  o.application_date = 12.days.ago.to_date
  o.status = "applied"
  o.remote = true
  o.salary_range = "$120,000 - $150,000"
  o.source = "indeed"
  o.role_type = "software_engineer"
  puts "  Created demo opportunity: #{o.position_title} @ #{brightpath.name}"
end
opp_bright.technologies = find_techs("React", "Node.js", "PostgreSQL", "TypeScript", "Docker")

opp_next = Opportunity.find_or_create_by!(company: nextstep, position_title: "Solutions Engineer") do |o|
  o.application_date = 20.days.ago.to_date
  o.status = "interviewing"
  o.remote = false
  o.salary_range = "$130,000 - $160,000"
  o.source = "referral"
  o.role_type = "sales_engineer"
  o.notes = "Referred by former colleague. Consulting model with client rotations."
  puts "  Created demo opportunity: #{o.position_title} @ #{nextstep.name}"
end
opp_next.technologies = find_techs("Python", "AWS", "Docker", "Kubernetes", "Terraform")

opp_core = Opportunity.find_or_create_by!(company: corestack, position_title: "Platform Engineer") do |o|
  o.application_date = 2.days.ago.to_date
  o.status = "applied"
  o.remote = true
  o.salary_range = "$160,000 - $195,000"
  o.source = "company_website"
  o.role_type = "software_engineer"
  puts "  Created demo opportunity: #{o.position_title} @ #{corestack.name}"
end
opp_core.technologies = find_techs("Go", "Kubernetes", "Docker", "AWS", "GitHub Actions")

opp_talent = Opportunity.find_or_create_by!(company: talentbridge, position_title: "Contract Rails Developer") do |o|
  o.application_date = 30.days.ago.to_date
  o.status = "closed"
  o.remote = true
  o.salary_range = "$75/hr"
  o.source = "staffing_agency"
  o.role_type = "software_engineer"
  o.notes = "6-month contract. Passed on due to rate below target."
  puts "  Created demo opportunity: #{o.position_title} @ #{talentbridge.name}"
end
opp_talent.technologies = find_techs("Ruby on Rails", "PostgreSQL", "React", "Redis")

# --- Demo Interview Sessions ---
sarah = Contact.find_by(name: "Sarah Chen")
james = Contact.find_by(name: "James Rivera")
priya = Contact.find_by(name: "Priya Patel")

InterviewSession.find_or_create_by!(opportunity: opp_acme, stage: "recruiter") do |i|
  i.contact = james
  i.scheduled_at = 3.days.ago
  i.duration_minutes = 30
  i.format = "video"
  i.status = "completed"
  i.overall_signal = "yes"
  i.confidence_score = 7
  i.notes = "Good conversation about team culture and growth plans."
  i.next_steps = "Technical interview scheduled for next week."
  puts "  Created demo interview: Recruiter Screen @ #{acme.name}"
end

InterviewSession.find_or_create_by!(opportunity: opp_acme, stage: "technical") do |i|
  i.contact = sarah
  i.scheduled_at = 2.days.from_now
  i.duration_minutes = 60
  i.format = "video"
  i.status = "planned"
  i.notes = "Expect system design questions around distributed systems."
  puts "  Created demo interview: Technical @ #{acme.name}"
end

InterviewSession.find_or_create_by!(opportunity: opp_next, stage: "hiring_manager") do |i|
  i.scheduled_at = 10.days.ago
  i.duration_minutes = 45
  i.format = "video"
  i.status = "completed"
  i.overall_signal = "strong_yes"
  i.confidence_score = 8
  i.notes = "Great discussion about client-facing work and pre-sales process."
  i.questions_they_asked = "Walk me through a time you translated complex technical concepts for a non-technical audience."
  i.next_steps = "Panel interview with two senior engineers."
  puts "  Created demo interview: Hiring Manager @ #{nextstep.name}"
end

# --- Demo STAR Stories ---
StarStory.find_or_create_by!(title: "Reduced API Response Time by 60%", user: demo_user) do |s|
  s.situation = "Our main API endpoint was averaging 800ms response times, causing timeouts for mobile clients and complaints from the sales team during demos."
  s.task = "I was tasked with identifying the bottleneck and bringing response times under 300ms without a full rewrite."
  s.action = "Profiled the request lifecycle using rack-mini-profiler, identified N+1 queries and unnecessary serialization. Implemented eager loading, added Redis caching for frequently accessed data, and introduced database indexing on the most-queried columns."
  s.result = "Response times dropped to 320ms (60% improvement). Mobile timeout errors fell to near-zero. The sales team specifically called out the improvement in their next QBR."
  s.category = "problem_solving"
  s.strength_score = 8
  s.times_used = 3
  s.skills = [ "Performance Optimization", "Ruby on Rails", "Redis", "SQL" ]
  puts "  Created demo STAR story: #{s.title}"
end

StarStory.find_or_create_by!(title: "Led Cross-Team Migration to Microservices", user: demo_user) do |s|
  s.situation = "The monolithic Rails app was becoming a deployment bottleneck — 45-minute deploy cycles and frequent merge conflicts across 4 teams."
  s.task = "Lead the architectural planning and first phase of extracting the billing domain into a standalone service."
  s.action = "Facilitated architecture review sessions, defined service boundaries using domain-driven design principles, built the billing service with a clear API contract, and implemented an event-driven integration pattern with the monolith."
  s.result = "Billing service deployed independently with 5-minute cycles. Zero billing-related deploy conflicts after extraction. Pattern became the template for 3 subsequent service extractions."
  s.category = "architecture"
  s.strength_score = 9
  s.times_used = 5
  s.skills = [ "System Design", "Microservices", "Leadership", "Domain-Driven Design" ]
  puts "  Created demo STAR story: #{s.title}"
end

StarStory.find_or_create_by!(title: "Resolved Production Incident Under Pressure", user: demo_user) do |s|
  s.situation = "Payment processing went down at 2 AM on a Friday during a flash sale event. Revenue loss estimated at $10K/hour."
  s.task = "Diagnose the root cause and restore service while coordinating with the on-call team and keeping stakeholders informed."
  s.action = "Traced the issue to a database connection pool exhaustion caused by a long-running background job that had been deployed earlier that day. Killed the runaway process, increased the pool temporarily, and deployed a fix to limit job concurrency."
  s.result = "Service restored in 22 minutes. Implemented connection pool monitoring and background job guardrails to prevent recurrence. Wrote a post-mortem that led to improved deploy-time testing for background jobs."
  s.category = "incident"
  s.strength_score = 7
  s.times_used = 2
  s.skills = [ "Incident Response", "PostgreSQL", "Debugging", "Communication" ]
  puts "  Created demo STAR story: #{s.title}"
end

# --- Demo Resource Guide Questions ---
ResourceGuideQuestion.find_or_create_by!(
  guide_type: "behavioral",
  question: "Tell me about a time you disagreed with a technical decision.",
  user: demo_user
) do |q|
  q.section_title = "Conflict & Collaboration"
  q.meaning = "They want to see how you handle disagreement professionally and whether you can advocate for your position while remaining open to other perspectives."
  q.response_approach = "Use a specific example where you disagreed, explain your reasoning, show how you communicated it, and highlight the outcome — whether you won or lost the argument."
  puts "  Created demo guide question: #{q.question.truncate(50)}"
end

ResourceGuideQuestion.find_or_create_by!(
  guide_type: "technical",
  question: "How would you design a rate limiter for an API?",
  user: demo_user
) do |q|
  q.section_title = "System Design"
  q.meaning = "Tests your understanding of distributed systems, trade-offs between algorithms (token bucket vs sliding window), and production considerations."
  q.response_approach = "Start with requirements (per-user vs global, precision needed), propose an algorithm, discuss storage (Redis), and address edge cases like distributed environments."
  puts "  Created demo guide question: #{q.question.truncate(50)}"
end

puts "\nDemo data seeding completed!"
puts "Demo companies: #{demo_user.companies.count}"
puts "Demo opportunities: #{demo_user.opportunities.count}"
puts "Demo contacts: #{demo_user.contacts.count}"
puts "Demo STAR stories: #{demo_user.star_stories.count}"
