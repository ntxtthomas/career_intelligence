class IndustryBackfill
  # Lowercased legacy free-text industry => [root] or [root, segment]; nil means the value is discarded.
  MAPPING = {
    "business intelligence" => [ "Business Intelligence" ],
    "cloud infrastructure" => [ "Cloud Infrastructure" ],
    "construction tech" => [ "ConstructionTech" ],
    "contractor tech" => [ "ConstructionTech" ],
    "cybersecurity" => [ "Cybersecurity" ],
    "devops / platform engineering" => [ "DevOps / Platform Engineering" ],
    "developer tools" => [ "Developer Tools" ],
    "e-commerce" => [ "E-commerce" ],
    "edtech" => [ "EdTech" ],
    "education" => [ "EdTech" ],
    "e-learning" => [ "EdTech" ],
    "entertainment" => [ "Entertainment" ],
    "fintech" => [ "FinTech" ],
    "foodtech" => [ "FoodTech" ],
    "govtech" => [ "GovTech" ],
    "hrtech" => [ "HRTech" ],
    "healthtech" => [ "HealthTech" ],
    "hospitalitytech" => [ "HospitalityTech" ],
    "insurancetech" => [ "InsuranceTech" ],
    "lawtech" => [ "LawTech" ],
    "mapping" => [ "Mapping" ],
    "non-profit church" => [ "Religious/Community" ],
    "non-profit training" => [ "EdTech" ],
    "proptech" => [ "PropTech" ],
    "real estate" => [ "PropTech" ],
    "real estate technology" => [ "PropTech" ],
    "real estate saas" => [ "PropTech" ],
    "publicsafetytech" => [ "PublicSafetyTech" ],
    "recruiter" => [ "Staffing" ],
    "staffing" => [ "Staffing" ],
    "technical staffing" => [ "Staffing" ],
    "saas" => [ "Technology" ],
    "generic saas" => [ "Technology" ],
    "software development" => [ "Technology" ],
    "technology" => [ "Technology" ],
    "technology consulting" => [ "Technology" ],
    "sanitation" => [ "Sanitation" ],
    "something" => nil
  }.freeze

  # Companies that already have an industry_id are left alone, so re-running is safe.
  def self.call
    IndustryCatalog.seed!

    report = { updated: 0, dropped: 0, unmapped: Hash.new(0) }

    Company.where(industry_id: nil).where.not(legacy_industry: [ nil, "" ]).find_each do |company|
      key = company.legacy_industry.strip.downcase

      unless MAPPING.key?(key)
        report[:unmapped][company.legacy_industry] += 1
        next
      end

      target = MAPPING[key]
      if target.nil?
        report[:dropped] += 1
        next
      end

      company.update_column(:industry_id, find_industry(*target).id)
      report[:updated] += 1
    end

    report
  end

  def self.find_industry(root_name, segment_name = nil)
    root = Industry.find_by!(name: root_name, parent_id: nil)
    segment_name ? Industry.find_by!(name: segment_name, parent_id: root.id) : root
  end
  private_class_method :find_industry
end
