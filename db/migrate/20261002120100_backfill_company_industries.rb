class BackfillCompanyIndustries < ActiveRecord::Migration[8.0]
  def up
    Company.reset_column_information
    Industry.reset_column_information

    report = IndustryBackfill.call

    say "Industries backfilled: #{report[:updated]} updated, #{report[:dropped]} dropped"
    report[:unmapped].each { |value, count| say "UNMAPPED industry #{value.inspect} (#{count} companies) left blank", true }
  end

  # legacy_industry still holds the original values, so there is nothing to undo.
  def down; end
end
