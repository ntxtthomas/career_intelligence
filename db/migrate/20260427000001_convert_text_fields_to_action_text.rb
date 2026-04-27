require "cgi"

class ConvertTextFieldsToActionText < ActiveRecord::Migration[8.0]
  def up
    # Remove NOT NULL constraint on resource_guide_questions.question —
    # ActionText stores this field in action_text_rich_texts, not in the column.
    change_column_null :resource_guide_questions, :question, true

    now = Time.current.utc.strftime("%Y-%m-%d %H:%M:%S")

    conversions = {
      "Company"               => { table: "companies",               fields: %w[primary_product market_size_estimate] },
      "Contact"               => { table: "contacts",                fields: %w[about notes] },
      "InterviewSession"      => { table: "interview_sessions",      fields: %w[questions_they_asked questions_i_asked follow_ups next_steps] },
      "Opportunity"           => { table: "opportunities",           fields: %w[other_tech_stack notes] },
      "ResourceGuideQuestion" => { table: "resource_guide_questions", fields: %w[question meaning response_approach example_response pitfall why_this_is_strong] },
      "ResourceSheet"         => { table: "resource_sheets",         fields: %w[about_me_content about_me_bullets why_company_content why_company_bullets why_me_content why_me_bullets salary_content salary_bullets notes_content notes_bullets] },
      "StarStory"             => { table: "star_stories",            fields: %w[situation task action result notes] }
    }

    conversions.each do |record_type, config|
      records = execute("SELECT id, #{config[:fields].join(", ")} FROM #{config[:table]}")

      records.each do |row|
        config[:fields].each do |field|
          text = row[field]
          next if text.nil? || text.strip.empty?

          body = trix_html(text)

          execute(<<~SQL)
            INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
            VALUES (
              #{quote(field)},
              #{quote(body)},
              #{quote(record_type)},
              #{row["id"].to_i},
              '#{now}',
              '#{now}'
            )
            ON CONFLICT (record_type, record_id, name) DO NOTHING
          SQL
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def trix_html(text)
    paragraphs = text.strip.split(/\n{2,}/).map do |para|
      lines = para.split("\n").map { |line| CGI.escapeHTML(line) }
      "<p>#{lines.join("<br>")}</p>"
    end.join
    "<div class=\"trix-content\">#{paragraphs}</div>"
  end
end
