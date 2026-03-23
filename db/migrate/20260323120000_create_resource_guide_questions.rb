class CreateResourceGuideQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :resource_guide_questions do |t|
      t.string :guide_type, null: false
      t.string :section_title
      t.text :question, null: false
      t.text :meaning
      t.text :response_approach
      t.text :example_response
      t.text :pitfall
      t.text :why_this_is_strong

      t.timestamps
    end

    add_index :resource_guide_questions, :guide_type
  end
end
