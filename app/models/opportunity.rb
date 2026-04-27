class Opportunity < ApplicationRecord
  # Include role-specific concerns
  include RoleTypes::SoftwareEngineer
  include RoleTypes::SalesEngineer
  include RoleTypes::SolutionsEngineer
  include RoleTypes::ProductManager
  include RoleTypes::SupportEngineer
  include RoleTypes::SuccessEngineer
  include RoleTypes::Other

  belongs_to :company

  has_rich_text :other_tech_stack
  has_rich_text :notes

  has_many :opportunity_technologies, dependent: :destroy
  has_many :technologies, through: :opportunity_technologies
  has_many :interview_sessions, dependent: :destroy
  has_many :resource_sheets, dependent: :nullify
  has_many :star_story_opportunities, dependent: :destroy
  has_many :star_stories, through: :star_story_opportunities

  accepts_nested_attributes_for :opportunity_technologies, allow_destroy: true

  # Delegate website and linkedin to the company
  delegate :website, :linkedin, to: :company, allow_nil: true

  # Role type enum
  ROLE_TYPES = {
    "software_engineer" => "Software Engineer",
    "sales_engineer" => "Sales Engineer",
    "solutions_engineer" => "Solutions Engineer",
    "product_manager" => "Product Manager",
    "support_engineer" => "Support Engineer",
    "success_engineer" => "Success Engineer",
    "other" => "Other"
  }.freeze

  # Career Intelligence Enums
  enum :retirement_plan_type, {
    four_oh_one_k: "401k",
    simple_ira: "simple_ira",
    none: "none",
    unknown: "unknown"
  }, prefix: :retirement

  enum :remote_type, {
    remote: "remote",
    hybrid: "hybrid",
    onsite: "onsite"
  }, prefix: :work

  enum :risk_level, {
    low: "low",
    medium: "medium",
    high: "high"
  }, prefix: :risk

  validates :role_type, presence: true, inclusion: { in: ROLE_TYPES.keys }
  validates :fit_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :trajectory_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validates :strategic_value, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true

  before_save :shorten_urls
  before_save :standardize_salary_range

  # Role type helper methods
  def role_type_label
    ROLE_TYPES[role_type] || role_type.titleize
  end

  def software_engineer?
    role_type == "software_engineer"
  end

  def sales_engineer?
    role_type == "sales_engineer"
  end

  def solutions_engineer?
    role_type == "solutions_engineer"
  end

  def product_manager?
    role_type == "product_manager"
  end

  def support_engineer?
    role_type == "support_engineer"
  end

  def success_engineer?
    role_type == "success_engineer"
  end

  def other?
    role_type == "other"
  end

  # Get/Set role metadata with indifferent access
  def metadata
    @metadata ||= (role_metadata || {}).with_indifferent_access
  end

  def metadata=(hash)
    self.role_metadata = hash
    @metadata = nil # Clear memoization
  end

  private

  def shorten_urls
    if listing_url_changed? && listing_url.present? && !listing_url.include?("is.gd")
      self.listing_url = UrlShortenerService.shorten(listing_url)
    end
  rescue StandardError => e
    Rails.logger.error("URL shortening failed in Opportunity#shorten_urls: #{e.message}")
    # Continue with save even if shortening fails
  end

  def standardize_salary_range
    return if salary_range.blank?

    # Remove leading/trailing whitespace
    normalized = salary_range.strip

    # Convert various dash/hyphen characters to standard hyphen
    normalized = normalized.gsub(/[–—−]/, "-")

    # Remove /yr, /Yr, /year suffixes first (before number processing)
    normalized = normalized.gsub(/\s*\/\s*(yr|Yr|year)\.?/i, "")

    # Special case: if one number has K and the range doesn't, assume both are in K
    # e.g., "$110-$125k" should become "$110k-$125k"
    if normalized.match(/\$(\d+)-\$(\d+)([kK])/)
      normalized = normalized.gsub(/\$(\d+)-\$(\d+)([kK])/, '$\1k-$\2k')
    end

    # Convert K notation to full numbers
    # Handle patterns like: $110k, $117k-$145k, $147K
    normalized = normalized.gsub(/\$(\d+)([kK])/) do
      "$#{$1.to_i * 1000}"
    end

    # Also handle numbers without $ that have K
    normalized = normalized.gsub(/(\d+)([kK])/) do
      "#{$1.to_i * 1000}"
    end

    # Remove commas from numbers
    normalized = normalized.gsub(/(\d),(\d)/, '\1\2')

    # Standardize separators: convert " - ", "–", "—" to single "-"
    normalized = normalized.gsub(/\s*[-–—]+\s*/, "-")

    # Remove trailing periods and extra spaces
    normalized = normalized.gsub(/\.\s*$/, "").strip

    # Final cleanup: ensure we have proper format
    self.salary_range = normalized
  rescue StandardError => e
    Rails.logger.error("Salary standardization failed: #{e.message}")
    # Keep original value if standardization fails
  end
end
