class StarStory < ApplicationRecord
  # Associations
  belongs_to :user

  has_many :star_story_opportunities, dependent: :destroy
  has_many :opportunities, through: :star_story_opportunities

  # Enums
  enum :category, {
    incident: "incident",
    technical_mistake: "technical_mistake",
    leadership: "leadership",
    devops: "devops",
    refactor: "refactor",
    conflict: "conflict",
    architecture: "architecture",
    scaling: "scaling",
    problem_solving: "problem_solving",
    collaboration: "collaboration",
    innovation: "innovation"
  }, prefix: true

  enum :outcome, {
    advanced: "advanced",
    rejected: "rejected",
    offer: "offer",
    unknown: "unknown"
  }, prefix: true

  # Validations
  validates :title, presence: true
  validates :strength_score, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }, allow_nil: true
  validates :times_used, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :top_rated, -> { where("strength_score >= ?", 4).order(strength_score: :desc) }
  scope :frequently_used, -> { where("times_used > ?", 2).order(times_used: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  scope :successful, -> { where(outcome: [ :advanced, :offer ]) }

  # Methods
  def mark_as_used!
    increment!(:times_used)
    update(last_used_at: Date.today)
  end

  def complete?
    situation.present? && task.present? && action.present? && result.present?
  end

  def incomplete_fields
    fields = []
    fields << "situation" if situation.blank?
    fields << "task" if task.blank?
    fields << "action" if action.blank?
    fields << "result" if result.blank?
    fields
  end
end
