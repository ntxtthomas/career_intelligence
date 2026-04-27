class InterviewSession < ApplicationRecord
  belongs_to :opportunity
  belongs_to :contact, optional: true
  has_rich_text :notes
  has_rich_text :questions_they_asked
  has_rich_text :questions_i_asked
  has_rich_text :follow_ups
  has_rich_text :next_steps

  enum :stage, {
    recruiter: "recruiter",
    hiring_manager: "hiring_manager",
    technical: "technical",
    panel: "panel",
    take_home: "take_home",
    final: "final",
    other: "other"
  }, prefix: true

  enum :format, {
    phone: "phone",
    video: "video",
    onsite: "onsite",
    async: "async"
  }, prefix: true

  enum :status, {
    planned: "planned",
    completed: "completed",
    cancelled: "cancelled"
  }, prefix: true

  enum :overall_signal, {
    strong_yes: "strong_yes",
    yes: "yes",
    neutral: "neutral",
    no: "no",
    strong_no: "strong_no"
  }, prefix: true

  validates :opportunity, presence: true
  validates :stage, presence: true
  validates :format, presence: true
  validates :status, presence: true
  validates :confidence_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }, allow_nil: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :recent, -> { order(scheduled_at: :desc) }
end
