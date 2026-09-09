class Company < ApplicationRecord
  belongs_to :user

  has_rich_text :primary_product
  has_rich_text :market_size_estimate

  has_many :contacts, dependent: :destroy
  has_many :opportunities, dependent: :destroy
  has_many :resource_sheets, dependent: :nullify

  before_validation :normalize_name
  before_save :sanitize_size

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
  validates :company_type, inclusion: { in: %w[Product Consultancy Staffing], message: "%{value} is not a valid company type" }, allow_nil: true
  validates :size, format: { with: /\A[\d,\-\s]*\z/, message: "should be a range like '501-1,000'" }, allow_nil: true, allow_blank: true

  # Enum for company type
  enum :company_type, {
    Product: "Product",
    Consultancy: "Consultancy",
    Staffing: "Staffing"
  }, validate: true

  scope :preferred, -> { where(preferred: true) }

  DOMAIN_MATCH_BY_INDUSTRY = {
    "proptech"                     => "deep",
    "real estate"                  => "deep",
    "real estate fintech"          => "deep",
    "edtech"                       => "deep",
    "3d/haptics"                   => "deep",
    "education benefits"           => "adjacent",
    "developer tools"              => "adjacent",
    "infrastructure/observability" => "adjacent",
    "generic saas"                 => "none",
    "e-commerce"                   => "none",
    "healthtech"                   => "none",
    "fintech"                      => "none",
    "govtech/federal"              => "none",
    "govtech"                      => "none",
    "cloud infrastructure"         => "none",
    "cybersecurity"                => "none",
    "software development"         => "none",
    "saas"                         => "none",
    "technology"                   => "none",
    "technology consulting"        => "none",
    "foodtech"                     => "none",
    "hrtech"                       => "none",
    "publicsafetytech"             => "none",
    "hospitalitytech"              => "none",
    "lawtech"                      => "none",
    "insurancetech"                => "none",
    "business intelligence"        => "none",
    "entertainment"                => "none",
    "sanitation"                   => "none",
    "mapping"                      => "none",
    "construction tech"            => "none",
    "contractor tech"              => "none",
    "devops / platform engineering" => "none",
    "non-profit church"            => "none",
    "non-profit training"          => "none"
  }.freeze

  def suggested_domain_match
    return nil if industry.blank?
    DOMAIN_MATCH_BY_INDUSTRY[industry.to_s.strip.downcase]
  end

  def tech_stack_summary
    opportunities
      .joins(:technologies)
      .select("DISTINCT technologies.name, technologies.category")
      .order("technologies.category, technologies.name")
  end

  def full_tech_stack_summary
    # Combine opportunity-derived techs with known techs
    opportunity_techs = opportunities
      .joins(:technologies)
      .select("DISTINCT technologies.name")
      .order(:name)
      .pluck(:name)

    known_techs = known_tech_stack.present? ? known_tech_stack.split(",").map(&:strip) : []

    (opportunity_techs + known_techs).uniq.sort
  end

  def tech_stack_with_sources
    # Returns array of hashes with tech name and source (opportunity or known)
    result = []

    # Add opportunity-derived technologies
    opportunities
      .joins(:technologies)
      .select("DISTINCT technologies.name, technologies.category")
      .order("technologies.category, technologies.name")
      .each do |tech|
        result << { name: tech.name, source: :opportunity, category: tech.category }
      end

    # Add known technologies not already in opportunities
    if known_tech_stack.present?
      known_techs = known_tech_stack.split(",").map(&:strip)
      known_techs.each do |tech_name|
        next if result.any? { |t| t[:name] == tech_name }
        result << { name: tech_name, source: :known, category: "Other" }
      end
    end

    result
  end

  private

  def normalize_name
    self.name = name.to_s.squish.presence
  end

  def sanitize_size
    self.size = size&.gsub(",", "") if size.present?
  end
end
