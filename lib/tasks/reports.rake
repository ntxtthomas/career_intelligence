namespace :reports do
  desc "Application counts per week (Sun-Sat) from the first application to today. Optional USER_ID=<id> to scope to a user."
  task weekly_applications: :environment do
    scope = ReportScope.opportunities

    first_date = scope.where.not(application_date: nil).minimum(:application_date)
    if first_date.nil?
      puts "No applications found."
      next
    end

    week_start = first_date - first_date.wday.days
    last_week_start = Date.today - Date.today.wday.days

    puts "Week Range,Count"
    while week_start <= last_week_start
      week_end = week_start + 6.days
      count = scope.where(application_date: week_start..week_end).count
      puts "#{week_start.strftime('%Y-%m-%d')} - #{week_end.strftime('%Y-%m-%d')},#{count}"
      week_start += 7.days
    end
  end

  desc "Opportunity and application count/percentage by industry. Optional USER_ID=<id> to scope to a user."
  task counts_by_industry: :environment do
    opportunities = ReportScope.opportunities.joins(:company)
    applications = opportunities.where.not(application_date: nil)

    total_opportunities = opportunities.count
    total_applications = applications.count

    puts "== Opportunities by industry (n=#{total_opportunities}) =="
    puts "Industry,Count,Percentage"
    opportunities.group("companies.industry").count.sort_by { |_, count| -count }.each do |industry, count|
      puts "#{industry || '(none)'},#{count},#{ReportScope.percentage(count, total_opportunities)}"
    end

    puts "\n== Applications by industry (n=#{total_applications}) =="
    puts "Industry,Count,Percentage"
    applications.group("companies.industry").count.sort_by { |_, count| -count }.each do |industry, count|
      puts "#{industry || '(none)'},#{count},#{ReportScope.percentage(count, total_applications)}"
    end
  end

  desc "Response/interview rate by industry, by company size, and cross-tabbed. Optional USER_ID=<id> to scope to a user."
  task response_interview_rates: :environment do
    applications = ReportScope.opportunities.where.not(application_date: nil).joins(:company)

    puts "== Response / interview rate by industry =="
    puts "Industry,Applications,Response Rate,Interview Rate"
    applications.group("companies.industry").count.sort_by { |_, count| -count }.each do |industry, total|
      scope = applications.where(companies: { industry: industry })
      puts "#{industry || '(none)'},#{total},#{ReportScope.response_rate(scope, total)},#{ReportScope.interview_rate(scope, total)}"
    end

    puts "\n== Response / interview rate by company size =="
    puts "Size,Applications,Response Rate,Interview Rate"
    applications.group("companies.size").count.sort_by { |_, count| -count }.each do |size, total|
      scope = applications.where(companies: { size: size })
      puts "#{size || '(none)'},#{total},#{ReportScope.response_rate(scope, total)},#{ReportScope.interview_rate(scope, total)}"
    end

    puts "\n== Response / interview rate by industry x company size =="
    puts "Industry,Size,Applications,Response Rate,Interview Rate"
    applications.group("companies.industry", "companies.size").count.sort_by { |_, count| -count }.each do |(industry, size), total|
      scope = applications.where(companies: { industry: industry, size: size })
      puts "#{industry || '(none)'},#{size || '(none)'},#{total},#{ReportScope.response_rate(scope, total)},#{ReportScope.interview_rate(scope, total)}"
    end
  end
end

# Shared helpers for the ad-hoc production report tasks above.
module ReportScope
  module_function

  def opportunities
    if ENV["USER_ID"].present?
      Opportunity.joins(:company).where(companies: { user_id: ENV["USER_ID"] })
    else
      Opportunity.all
    end
  end

  def percentage(numerator, denominator)
    return 0.0 unless denominator.to_i.positive?

    ((numerator.to_f / denominator) * 100).round(1)
  end

  def response_rate(scope, total)
    responded = scope.where(response_type: %w[human automated]).count
    "#{percentage(responded, total)}%"
  end

  def interview_rate(scope, total)
    interviewed = scope.joins(:interview_sessions).distinct.count
    "#{percentage(interviewed, total)}%"
  end
end
