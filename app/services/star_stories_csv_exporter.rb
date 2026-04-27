require "csv"

class StarStoriesCsvExporter
  def initialize(star_stories)
    @star_stories = star_stories
  end

  def generate
    CSV.generate(headers: true, write_headers: true, force_quotes: true) do |csv|
      csv << headers

      @star_stories.each do |story|
        csv << [
          sanitize_for_excel(story.title),
          sanitize_for_excel(story.situation),
          sanitize_for_excel(story.task),
          sanitize_for_excel(story.action),
          sanitize_for_excel(story.result),
          sanitize_for_excel(story.skills&.join(", ")),
          sanitize_for_excel(story.category&.titleize),
          sanitize_for_excel(story.notes)
        ]
      end
    end
  end

  private

  def sanitize_for_excel(value)
    return "" if value.nil? || value.to_s.strip.empty?

    str = value.to_s
    # Prefix with single quote if starts with formula characters to prevent Excel interpretation
    if str.match?(/^[-=+@]/)
      "'#{str}"
    else
      str
    end
  end

  def headers
    [
      "Title",
      "Situation",
      "Task",
      "Action",
      "Result",
      "Skills",
      "Category",
      "Notes"
    ]
  end
end
