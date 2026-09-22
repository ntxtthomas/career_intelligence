class ExperimentAnalyzer
  def initialize(opportunities)
    @opportunities = opportunities
  end

  # Conversion rate (submitted -> interviewed) grouped by acquisition channel
  def conversion_by_channel
    conversion_by(:acquisition_channel)
  end

  # Conversion rate (submitted -> interviewed) grouped by domain match
  def conversion_by_domain_match
    conversion_by(:domain_match)
  end

  # Conversion rate (submitted -> interviewed) grouped by whether a fit map was used
  def conversion_by_fit_map
    conversion_by(:fit_map_used)
  end

  # Raw response rate (anything but no_response) and human response rate (human only)
  def response_rate_breakdown
    total = @opportunities.count

    responded_count = @opportunities.where(response_type: ["human", "automated"]).count
    human_count = @opportunities.where(response_type: "human").count

    {
      raw_response: rate_hash(responded_count, total),
      human_response: rate_hash(human_count, total)
    }
  end

  # Response/interview rate grouped by company industry
  def response_interview_by_industry
    grouped_response_interview_stats(:industry)
  end

  # Response/interview rate grouped by company size (employee range)
  def response_interview_by_company_size
    grouped_response_interview_stats(:size)
  end

  # Response/interview rate cross-tabbed by industry x company size, dropping combos below min_sample
  def response_interview_by_industry_and_size(min_sample: 3)
    scope = @opportunities.joins(:company)

    scope.group("companies.industry", "companies.size").count.each_with_object({}) do |(key, count), result|
      next if count < min_sample

      industry, size = key
      filtered = scope.where(companies: { industry: industry, size: size })
      result[[ industry, size ]] = response_interview_stats(filtered, count)
    end
  end

  private

  def conversion_by(column)
    @opportunities.group(column).count.each_with_object({}) do |(value, count), result|
      interviewed = @opportunities.where(column => value).joins(:interview_sessions).distinct.count

      result[value] = {
        count: count,
        interviewed: interviewed,
        rate: percentage(interviewed, count)
      }
    end
  end

  def grouped_response_interview_stats(company_column)
    scope = @opportunities.joins(:company)

    scope.group("companies.#{company_column}").count.each_with_object({}) do |(value, count), result|
      filtered = scope.where(companies: { company_column => value })
      result[value] = response_interview_stats(filtered, count)
    end
  end

  def response_interview_stats(scope, count)
    responded = scope.where(response_type: %w[human automated]).count
    interviewed = scope.joins(:interview_sessions).distinct.count

    {
      count: count,
      responded: responded,
      response_rate: percentage(responded, count),
      interviewed: interviewed,
      interview_rate: percentage(interviewed, count)
    }
  end

  def rate_hash(numerator, denominator)
    {
      count: numerator,
      denominator: denominator,
      rate: percentage(numerator, denominator)
    }
  end

  def percentage(numerator, denominator)
    return 0.0 unless denominator.positive?

    ((numerator.to_f / denominator) * 100).round(1)
  end
end
