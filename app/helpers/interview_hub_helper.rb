module InterviewHubHelper
  # Interview Hub sub-nav tabs. Adding a future tab is a one-line addition here;
  # the partial at app/views/shared/_interview_hub_nav.html.erb renders whatever is listed.
  INTERVIEW_HUB_TABS = [
    { key: :sessions, label: "Sessions", path_helper: :interview_sessions_path },
    { key: :prep_sheets, label: "Prep Sheets", path_helper: :resource_sheets_path },
    { key: :star_stories, label: "STAR Stories", path_helper: :star_stories_path },
    { key: :guides, label: "Guides", path_helper: :guides_path }
  ].freeze

  def interview_hub_tabs
    INTERVIEW_HUB_TABS.map { |tab| tab.merge(path: send(tab[:path_helper])) }
  end

  def interview_hub_tab_classes(active)
    base = "px-3 py-2 text-sm no-underline whitespace-nowrap border-b-2 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-blue-500"

    if active
      "#{base} border-blue-500 text-blue-700 dark:text-blue-300 font-semibold"
    else
      "#{base} border-transparent text-[var(--text-secondary)] hover:text-blue-600 dark:hover:text-blue-400 hover:border-[var(--border-color)]"
    end
  end
end
