class AddExperimentFieldsToOpportunities < ActiveRecord::Migration[8.0]
  def change
    add_column :opportunities, :acquisition_channel, :string, default: "unknown", null: false
    add_column :opportunities, :domain_match, :string, default: "unknown", null: false
    add_column :opportunities, :fit_map_used, :boolean, default: false, null: false
    add_column :opportunities, :response_type, :string, default: "unknown", null: false

    add_index :opportunities, :acquisition_channel
    add_index :opportunities, :domain_match
    add_index :opportunities, :response_type
  end
end
