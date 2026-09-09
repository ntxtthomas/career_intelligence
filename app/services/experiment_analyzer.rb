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

    responded_count = @opportunities.where.not(response_type: "no_response").count
    human_count = @opportunities.where(response_type: "human").count

    {
      raw_response: rate_hash(responded_count, total),
      human_response: rate_hash(human_count, total)
    }
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
