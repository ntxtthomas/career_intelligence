class AddDefinitionToIndustries < ActiveRecord::Migration[8.0]
  def change
    add_column :industries, :definition, :text
  end
end
