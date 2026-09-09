require "rails_helper"
require "rake"

RSpec.describe "career_intelligence:backfill_domain_match" do
  let(:user) { create(:user) }

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?("career_intelligence:backfill_domain_match")
  end

  before do
    Rake::Task["career_intelligence:backfill_domain_match"].reenable
  end

  it "backfills matched industries, leaves unmatched as unknown, and skips already-set opportunities" do
    matched_company = Company.create!(name: "Matched Co #{SecureRandom.hex(4)}", industry: "PropTech", company_type: "Product", user: user)
    unmatched_company = Company.create!(name: "Unmatched Co #{SecureRandom.hex(4)}", industry: "Widgets", company_type: "Product", user: user)

    to_backfill = Opportunity.create!(company: matched_company, role_type: "software_engineer")
    to_backfill.update_column(:domain_match, "unknown")

    no_match = Opportunity.create!(company: unmatched_company, role_type: "software_engineer")
    no_match.update_column(:domain_match, "unknown")

    already_set = Opportunity.create!(company: matched_company, role_type: "software_engineer", domain_match: "adjacent")

    expect { Rake::Task["career_intelligence:backfill_domain_match"].invoke }
      .to output(/Backfilled 1 opportunities\. Left unknown \(no industry match\): 1\./).to_stdout

    expect(to_backfill.reload.domain_match).to eq("deep")
    expect(no_match.reload.domain_match).to eq("unknown")
    expect(already_set.reload.domain_match).to eq("adjacent")
  end

  it "uses update_column so it does not re-trigger unrelated save callbacks" do
    matched_company = Company.create!(name: "Callback Co #{SecureRandom.hex(4)}", industry: "PropTech", company_type: "Product", user: user)
    opportunity = Opportunity.create!(company: matched_company, role_type: "software_engineer", salary_range: "$110k-$125k")
    opportunity.update_column(:domain_match, "unknown")

    allow_any_instance_of(Opportunity).to receive(:shorten_urls).and_raise("shorten_urls should not run")
    allow_any_instance_of(Opportunity).to receive(:standardize_salary_range).and_raise("standardize_salary_range should not run")

    expect { Rake::Task["career_intelligence:backfill_domain_match"].invoke }.not_to raise_error

    expect(opportunity.reload.domain_match).to eq("deep")
    expect(opportunity.salary_range).to eq("$110000-$125000")
  end
end
