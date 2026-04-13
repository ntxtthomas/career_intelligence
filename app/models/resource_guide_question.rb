class ResourceGuideQuestion < ApplicationRecord
  belongs_to :user

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
