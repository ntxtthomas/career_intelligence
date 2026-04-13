namespace :demo do
  desc "Reset demo user data — destroys all demo records and re-seeds them"
  task reset: :environment do
    demo_user = User.find_by(demo: true)

    unless demo_user
      puts "No demo user found. Run `rails db:seed` first."
      exit 1
    end

    puts "Resetting demo data for #{demo_user.email}..."

    # Destroy in dependency order (children before parents)
    destroyed = {
      interview_sessions: InterviewSession.joins(opportunity: :company).where(companies: { user_id: demo_user.id }).delete_all,
      star_story_opportunities: StarStoryOpportunity.joins(:star_story).where(star_stories: { user_id: demo_user.id }).delete_all,
      resource_sheets: demo_user.resource_sheets.delete_all,
      resource_guide_questions: demo_user.resource_guide_questions.delete_all,
      star_stories: demo_user.star_stories.delete_all,
      core_narratives: demo_user.core_narratives.delete_all,
      companies: demo_user.companies.destroy_all.size  # destroy_all to cascade contacts/opportunities
    }

    destroyed.each { |model, count| puts "  Deleted #{count} #{model}" }

    puts "\nRe-seeding demo data..."
    Rake::Task["db:seed"].invoke

    puts "\nDemo reset complete!"
    puts "Demo companies: #{demo_user.reload.companies.count}"
    puts "Demo opportunities: #{demo_user.opportunities.count}"
    puts "Demo contacts: #{demo_user.contacts.count}"
    puts "Demo STAR stories: #{demo_user.star_stories.count}"
  end
end
