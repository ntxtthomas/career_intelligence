class RemoveOutcomeFromStarStories < ActiveRecord::Migration[8.0]
  def change
    remove_column :star_stories, :outcome, :string
  end
end
