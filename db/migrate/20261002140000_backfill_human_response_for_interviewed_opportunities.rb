class BackfillHumanResponseForInterviewedOpportunities < ActiveRecord::Migration[8.0]
  def up
    execute <<~SQL.squish
      UPDATE opportunities SET response_type = 'human'
      WHERE response_type <> 'human'
        AND EXISTS (SELECT 1 FROM interview_sessions WHERE interview_sessions.opportunity_id = opportunities.id)
    SQL
  end

  # The previous response_type values are not recoverable.
  def down; end
end
