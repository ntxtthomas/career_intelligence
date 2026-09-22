class DashboardController < ApplicationController
  def index
    opportunities = current_or_demo_user.opportunities
    submitted_opportunities = opportunities.where.not(application_date: nil)

    @total_resumes = submitted_opportunities.count
    @total_open_applications = opportunities.where(status: %w[applied interviewing]).count
    # Count interview processes, not interview rounds: 1 per submitted opportunity that has interviews.
    @total_interviews = submitted_opportunities.joins(:interview_sessions).distinct.count
    @interview_conversion_rate = if @total_resumes.positive?
      ((@total_interviews.to_f / @total_resumes) * 100).round(1)
    else
      0.0
    end

    pulse_vote_cookie = cookies.encrypted[:community_pulse_daily_votes]
    pulse_daily_count = if pulse_vote_cookie.is_a?(Hash) && (pulse_vote_cookie["date"] || pulse_vote_cookie[:date]) == Date.current.iso8601
      (pulse_vote_cookie["count"] || pulse_vote_cookie[:count]).to_i
    else
      0
    end
    @pulse_votes_remaining = [ CommunityPulseVotesController::DAILY_LIMIT_MAX - pulse_daily_count, 0 ].max

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

    # Industry breakdown (opportunities vs. applications)
    @opportunities_by_industry = opportunities.joins(:company)
                              .where.not(companies: { industry: [ nil, "" ] })
                              .group("companies.industry")
                              .count
                              .sort_by { |_, count| -count }
                              .to_h

    @applications_by_industry = submitted_opportunities.joins(:company)
                              .where.not(companies: { industry: [ nil, "" ] })
                              .group("companies.industry")
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
