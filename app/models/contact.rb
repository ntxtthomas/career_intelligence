class Contact < ApplicationRecord
  belongs_to :company

  has_rich_text :about
  has_rich_text :notes

  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true, allow_blank: true
end

