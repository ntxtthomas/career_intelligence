class Industry < ApplicationRecord
  DOMAIN_MATCHES = %w[none adjacent direct deep].freeze

  # Joins an opportunities relation (already joined to companies) to its industry and the industry's parent.
  JOINS_SQL = "LEFT JOIN industries ON industries.id = companies.industry_id " \
              "LEFT JOIN industries parent_industries ON parent_industries.id = industries.parent_id".freeze
  ROOT_NAME_SQL = "COALESCE(parent_industries.name, industries.name)".freeze

  belongs_to :parent, class_name: "Industry", optional: true
  has_many :children, class_name: "Industry", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error
  has_many :companies, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { scope: :parent_id, case_sensitive: false }
  validates :domain_match, inclusion: { in: DOMAIN_MATCHES }, allow_blank: true
  validate :hierarchy_is_one_level_deep

  scope :roots, -> { where(parent_id: nil) }
  scope :segments, -> { where.not(parent_id: nil) }

  # Roots followed by their segments, e.g. "EdTech" then "EdTech: Family Engagement".
  def self.for_select
    includes(:parent).sort_by { |industry| industry.full_name.downcase }
  end

  def full_name
    parent ? "#{parent.name}: #{name}" : name
  end

  def effective_domain_match
    domain_match.presence || parent&.domain_match.presence
  end

  def self_and_child_ids
    [ id, *children.pluck(:id) ]
  end

  private

  def hierarchy_is_one_level_deep
    errors.add(:parent, "must be a top-level industry") if parent&.parent_id.present?
    errors.add(:parent, "cannot be set on an industry that has segments") if parent_id.present? && persisted? && children.exists?
  end
end
