class Contact < ApplicationRecord
  belongs_to :company

  has_rich_text :about
  has_rich_text :notes

  before_save :shorten_urls

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true, allow_blank: true

  private

  def shorten_urls
    if linkedin_changed? && linkedin.present? && !linkedin.include?("is.gd")
      shortened = UrlShortenerService.shorten(linkedin)
      self.linkedin = shortened if shortened.present?
    end
  rescue StandardError => e
    Rails.logger.error("URL shortening failed in Contact#shorten_urls: #{e.message}")
    # Continue with save even if shortening fails
  end
end
