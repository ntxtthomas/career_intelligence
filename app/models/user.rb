class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :companies, dependent: :destroy
  has_many :contacts, through: :companies
  has_many :opportunities, through: :companies
  has_many :star_stories, dependent: :destroy
  has_many :core_narratives, dependent: :destroy
  has_many :resource_guide_questions, dependent: :destroy
  has_many :resource_sheets, dependent: :destroy
end
