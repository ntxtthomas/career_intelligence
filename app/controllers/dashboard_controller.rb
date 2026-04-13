class DashboardController < ApplicationController
  def index
    opportunities = current_or_demo_user.opportunities

    @total_resumes = opportunities.where.not(application_date: nil).count
    @total_open_applications = opportunities.where(status: %w[applied interviewing]).count
    @total_assessed = opportunities.count

    # Role-based focus insights
    focus_analyzer = RoleFocusAnalyzer.new(opportunities)
    @focus_insights = focus_analyzer.generate_insights(limit: 4)
    @all_role_insights = focus_analyzer.generate_all_role_insights(limit_per_role: 3)

    # Get primary role for main widget
    role_distribution = opportunities.group(:role_type).count.sort_by { |_role, count| -count }.to_h
    @primary_role = role_distribution.max_by { |_role, count| count }&.first

    # Source breakdown
    @source_data = opportunities.where.not(source: [ nil, "" ])
                              .group(:source)
                              .count
                              .sort_by { |_, count| -count }
                              .to_h

    # Applications by week (last 4 weeks)
    @weekly_data = calculate_weekly_applications
  end

  private

  def calculate_weekly_applications
    today = Date.today
    weeks = []

    # TWC (Texas Workforce Commission) weeks: Sunday through Saturday
    # Calculate days back to find the most recent Sunday
    days_back_to_sunday = today.wday  # Sunday is 0, so wday gives us days since Sunday
    current_week_start = today - days_back_to_sunday.days
    current_week_end = current_week_start + 6.days

    # Show current week + 3 previous weeks
    4.times do |i|
      if i == 0
        week_start = current_week_start
        week_end = current_week_end
      else
        week_end = current_week_start - 1.day
        week_start = week_end - 6.days
        current_week_start = week_start
      end

      count = current_or_demo_user.opportunities.where(application_date: week_start..week_end).count

      weeks << {
        label: "#{week_start.strftime('%b %d')} - #{week_end.strftime('%b %d')}",
        count: count,
        start_date: week_start,
        end_date: week_end,
        week_number: i,
        meets_requirement: count >= 5
      }
    end

    weeks
  end
end
