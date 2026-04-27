class ResourceSheet < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  belongs_to :opportunity, optional: true
  has_rich_text :about_me_content
  has_rich_text :about_me_bullets
  has_rich_text :why_company_content
  has_rich_text :why_company_bullets
  has_rich_text :why_me_content
  has_rich_text :why_me_bullets
  has_rich_text :salary_content
  has_rich_text :salary_bullets
  has_rich_text :notes_content
  has_rich_text :notes_bullets
  RESOURCE_TYPES = {
    interview_prep: "Interview Prep"
  }.freeze

  enum :resource_type, RESOURCE_TYPES.transform_values { |value| value.parameterize.underscore }, prefix: true

  validates :title, presence: true
  validates :resource_type, presence: true

  scope :recent, -> { order(updated_at: :desc) }
end
