class DropUnusedCompanyAndOpportunityFields < ActiveRecord::Migration[8.0]
  def up
    # ActionText stores these fields' data separately from the column being dropped.
    execute <<~SQL
      DELETE FROM action_text_rich_texts
      WHERE (record_type = 'Company' AND name = 'market_size_estimate')
         OR (record_type = 'Opportunity' AND name = 'other_tech_stack')
    SQL

    remove_column :companies, :revenue_model, :string
    remove_column :companies, :funding_stage, :string
    remove_column :companies, :estimated_revenue, :string
    remove_column :companies, :estimated_employees, :integer
    remove_column :companies, :growth_signal, :string
    remove_column :companies, :product_maturity, :integer
    remove_column :companies, :engineering_maturity, :integer
    remove_column :companies, :process_maturity, :integer
    remove_column :companies, :market_position, :string
    remove_column :companies, :competitor_tier, :string
    remove_column :companies, :brand_signal_strength, :integer
    remove_column :companies, :market_size_estimate, :text

    remove_column :opportunities, :other_tech_stack, :text
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
