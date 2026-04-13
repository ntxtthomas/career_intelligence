class AddUserIdToModels < ActiveRecord::Migration[8.0]
  def up
    # Add nullable columns first
    add_reference :companies, :user, null: true, foreign_key: true
    add_reference :star_stories, :user, null: true, foreign_key: true
    add_reference :core_narratives, :user, null: true, foreign_key: true
    add_reference :resource_guide_questions, :user, null: true, foreign_key: true
    add_reference :resource_sheets, :user, null: true, foreign_key: true

    # Create owner user and assign all existing records to them (this is real data)
    owner = User.find_or_create_by!(email: ENV.fetch("OWNER_EMAIL", "owner@jobtracker.dev")) do |u|
      u.password = ENV.fetch("OWNER_PASSWORD", "changeme123")
      u.demo = false
    end

    %i[companies star_stories core_narratives resource_guide_questions resource_sheets].each do |table|
      execute "UPDATE #{table} SET user_id = #{owner.id} WHERE user_id IS NULL"
    end

    # Now enforce NOT NULL
    change_column_null :companies, :user_id, false
    change_column_null :star_stories, :user_id, false
    change_column_null :core_narratives, :user_id, false
    change_column_null :resource_guide_questions, :user_id, false
    change_column_null :resource_sheets, :user_id, false
  end

  def down
    remove_reference :companies, :user
    remove_reference :star_stories, :user
    remove_reference :core_narratives, :user
    remove_reference :resource_guide_questions, :user
    remove_reference :resource_sheets, :user
  end
end
