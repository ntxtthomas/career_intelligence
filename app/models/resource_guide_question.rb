class ResourceGuideQuestion < ApplicationRecord
  belongs_to :user

  has_rich_text :question
  has_rich_text :meaning
  has_rich_text :response_approach
  has_rich_text :example_response
  has_rich_text :pitfall
  has_rich_text :why_this_is_strong

  enum :guide_type, {
    behavioral: "behavioral",
    technical: "technical",
    interviewer_questions: "interviewer_questions",
    acquired_questions: "acquired_questions"
  }, prefix: true

  validates :guide_type, presence: true
  validates :question, presence: true

  scope :for_guide, ->(guide_type) { where(guide_type: guide_type) }
  scope :ordered, -> { order(Arel.sql("COALESCE(section_title, '') ASC"), :created_at) }
end
