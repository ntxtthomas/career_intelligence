class CreateIndustries < ActiveRecord::Migration[8.0]
  def change
    create_table :industries do |t|
      t.string :name, null: false
      t.references :parent, foreign_key: { to_table: :industries }
      t.string :domain_match
      t.timestamps
    end

    add_index :industries, "lower(name), COALESCE(parent_id, 0)", unique: true, name: "index_industries_on_lower_name_and_parent"

    add_reference :companies, :industry, foreign_key: true

    # Kept until the backfill is verified in production; dropped in a follow-up migration.
    rename_column :companies, :industry, :legacy_industry
  end
end
