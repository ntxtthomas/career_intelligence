require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:companies).dependent(:destroy) }
    it { should have_many(:contacts).through(:companies) }
    it { should have_many(:opportunities).through(:companies) }
    it { should have_many(:star_stories).dependent(:destroy) }
    it { should have_many(:core_narratives).dependent(:destroy) }
    it { should have_many(:resource_guide_questions).dependent(:destroy) }
    it { should have_many(:resource_sheets).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
  end

  describe 'demo flag' do
    it 'defaults demo to false' do
      user = create(:user)
      expect(user.demo).to be false
    end

    it 'can create a demo user' do
      user = create(:user, :demo)
      expect(user.demo).to be true
    end
  end
end
