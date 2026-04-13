class ResourceSheet < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true
  belongs_to :opportunity, optional: true

  RESOURCE_TYPES = {
    interview_prep: "Interview Prep"
  }.freeze

  enum :resource_type, RESOURCE_TYPES.transform_values { |value| value.parameterize.underscore }, prefix: true

  validates :title, presence: true
  validates :resource_type, presence: true

  scope :recent, -> { order(updated_at: :desc) }
end
