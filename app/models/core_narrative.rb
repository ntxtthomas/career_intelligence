class CoreNarrative < ApplicationRecord
  belongs_to :user

  # Enums
  enum :narrative_type, {
    about_me: "about_me",
    why_company: "why_company",
    why_me: "why_me",
    salary: "salary",
    remote_positioning: "remote_positioning",
    leadership: "leadership",
    technical_depth: "technical_depth",
    career_trajectory: "career_trajectory"
  }, prefix: true

  enum :role_target, {
    software_engineer: "software_engineer",
    sales_engineer: "sales_engineer",
    solutions_engineer: "solutions_engineer",
    product_manager: "product_manager",
    support_engineer: "support_engineer",
    success_engineer: "success_engineer",
    devops: "devops",
    hybrid: "hybrid",
    universal: "universal"
  }, prefix: true

  # Validations
  validates :narrative_type, presence: true
  validates :content, presence: true

  # Callbacks
  before_save :set_last_updated, if: :content_changed?

  # Scopes
  scope :for_role, ->(role) { where(role_target: [ role, :universal ]) }
  scope :by_type, ->(type) { where(narrative_type: type) }
  scope :recently_updated, -> { where("last_updated >= ?", 30.days.ago).order(last_updated: :desc) }
  scope :current_version, -> { where(version: "current").or(where(version: nil)) }

  # Methods
  def word_count
    content.to_s.split.size
  end

  def estimated_reading_time
    # Average reading speed: 200 words per minute
    (word_count / 200.0).ceil
  end

  def needs_update?
    return true if last_updated.nil?

    last_updated < 60.days.ago
  end

  private

  def set_last_updated
    self.last_updated = Date.today
  end
end
