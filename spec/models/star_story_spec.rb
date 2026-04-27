require 'rails_helper'

RSpec.describe StarStory, type: :model do
  let(:user) { create(:user) }

  describe 'associations' do
    it { should have_many(:star_story_opportunities).dependent(:destroy) }
    it { should have_many(:opportunities).through(:star_story_opportunities) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }

    it 'validates strength_score is between 1 and 10' do
      story = StarStory.new(title: "Test", strength_score: 11, user: user)
      expect(story).not_to be_valid
      expect(story.errors[:strength_score]).to include("must be less than or equal to 10")
    end

    it 'validates times_used is non-negative' do
      story = StarStory.new(title: "Test", times_used: -1, user: user)
      expect(story).not_to be_valid
    end
  end

  describe 'enums' do
    it 'defines category enum' do
      expect(StarStory.categories.keys).to include('incident', 'leadership', 'devops')
    end
  end

  describe 'scopes' do
    let!(:top_story) { StarStory.create!(title: "Top Story", strength_score: 5, user: user) }
    let!(:weak_story) { StarStory.create!(title: "Weak Story", strength_score: 2, user: user) }
    let!(:frequent_story) { StarStory.create!(title: "Frequent", times_used: 5, user: user) }
    let!(:rare_story) { StarStory.create!(title: "Rare", times_used: 1, user: user) }

    describe '.top_rated' do
      it 'returns stories with strength_score >= 4' do
        expect(StarStory.top_rated).to include(top_story)
        expect(StarStory.top_rated).not_to include(weak_story)
      end
    end

    describe '.frequently_used' do
      it 'returns stories used more than 2 times' do
        expect(StarStory.frequently_used).to include(frequent_story)
        expect(StarStory.frequently_used).not_to include(rare_story)
      end
    end

  end

  describe '#mark_as_used!' do
    let(:story) { StarStory.create!(title: "Test Story", times_used: 0, user: user) }

    it 'increments times_used' do
      expect { story.mark_as_used! }.to change { story.times_used }.by(1)
    end

    it 'updates last_used_at to today' do
      story.mark_as_used!
      expect(story.last_used_at).to eq(Date.today)
    end
  end

  describe '#complete?' do
    it 'returns true when all STAR fields are present' do
      story = StarStory.new(
        title: "Complete",
        situation: "S",
        task: "T",
        action: "A",
        result: "R",
        user: user
      )
      expect(story.complete?).to be true
    end

    it 'returns false when any STAR field is missing' do
      story = StarStory.new(title: "Incomplete", situation: "S", task: "T", user: user)
      expect(story.complete?).to be false
    end
  end

  describe '#incomplete_fields' do
    it 'returns array of missing STAR fields' do
      story = StarStory.new(title: "Test", situation: "S", task: "T", user: user)
      expect(story.incomplete_fields).to contain_exactly("action", "result")
    end

    it 'returns empty array when complete' do
      story = StarStory.new(
        title: "Complete",
        situation: "S",
        task: "T",
        action: "A",
        result: "R",
        user: user
      )
      expect(story.incomplete_fields).to be_empty
    end
  end
end
