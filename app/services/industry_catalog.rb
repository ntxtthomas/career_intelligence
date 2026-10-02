class IndustryCatalog
  # name => domain_match (how closely the industry matches the owner's background)
  ROOTS = {
    "3D/Haptics" => "deep",
    "Business Intelligence" => "none",
    "Cloud Infrastructure" => "none",
    "ConstructionTech" => "none",
    "Cybersecurity" => "none",
    "Developer Tools" => "adjacent",
    "DevOps / Platform Engineering" => "none",
    "E-commerce" => "none",
    "EdTech" => "deep",
    "Entertainment" => "none",
    "FinTech" => "none",
    "FoodTech" => "none",
    "GovTech" => "none",
    "HealthTech" => "none",
    "HospitalityTech" => "none",
    "HRTech" => "none",
    "InsuranceTech" => "none",
    "LawTech" => "none",
    "Mapping" => "none",
    "PropTech" => "deep",
    "PublicSafetyTech" => "none",
    "Religious/Community" => "none",
    "Sanitation" => "none",
    "Staffing" => "none",
    "Technology" => "none"
  }.freeze

  # root name => { segment name => domain_match, nil inherits from the root }
  SEGMENTS = {
    "EdTech" => {
      "Administrative" => nil,
      "Child Care" => nil,
      "E-Learning" => "adjacent",
      "Early Childhood Development" => nil,
      "Family Engagement" => nil,
      "Higher Ed" => nil,
      "Homeschooling" => nil,
      "K-12" => nil
    }
  }.freeze

  # Idempotent: only creates what is missing, so edits made later are never overwritten.
  def self.seed!
    ROOTS.each do |name, domain_match|
      Industry.find_or_create_by!(name: name, parent_id: nil) { |industry| industry.domain_match = domain_match }
    end

    SEGMENTS.each do |root_name, segments|
      root = Industry.find_by!(name: root_name, parent_id: nil)
      segments.each do |name, domain_match|
        Industry.find_or_create_by!(name: name, parent_id: root.id) { |industry| industry.domain_match = domain_match }
      end
    end
  end
end
