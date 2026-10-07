module ApplicationHelper
  # Controllers that fall under each top-level nav link, for active-link highlighting.
  TOP_NAV_SECTIONS = {
    companies: %w[companies],
    opportunities: %w[opportunities],
    contacts: %w[contacts],
    interview_hub: %w[interview_sessions resource_sheets star_stories resource_guide_questions],
    experiments: %w[experiments]
  }.freeze

  def top_nav_active?(section)
    TOP_NAV_SECTIONS.fetch(section, []).include?(controller_name)
  end

  def top_nav_link_classes(active, mobile: false)
    base = "no-underline px-3 py-2 rounded-md text-sm focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-500"

    if active
      "#{base} text-blue-700 dark:text-blue-300 bg-[var(--bg-tertiary)] font-semibold"
    elsif mobile
      "#{base} text-blue-500 dark:text-blue-400 hover:bg-[var(--bg-tertiary)]"
    else
      "#{base} text-blue-500 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300"
    end
  end

  def sortable_link(column, title = nil)
    title ||= column.to_s.humanize
    direction = column.to_s == params[:sort] && params[:direction] == "asc" ? "desc" : "asc"
    icon = ""

    if column.to_s == params[:sort]
      icon = params[:direction] == "asc" ? " ▲" : " ▼"
    end

    link_to "#{title}#{icon}".html_safe,
            request.params.merge(sort: column, direction: direction),
            style: "text-decoration: none; color: inherit; font-weight: bold;"
  end
end
