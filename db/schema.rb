# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_04_27_000002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "industry"
    t.string "location"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linkedin"
    t.text "known_tech_stack"
    t.string "company_type"
    t.string "size"
    t.text "primary_product"
    t.string "revenue_model"
    t.string "funding_stage"
    t.string "estimated_revenue"
    t.integer "estimated_employees"
    t.string "growth_signal"
    t.integer "product_maturity"
    t.integer "engineering_maturity"
    t.integer "process_maturity"
    t.string "market_position"
    t.string "competitor_tier"
    t.integer "brand_signal_strength"
    t.text "market_size_estimate"
    t.string "market_growth_rate"
    t.string "regulatory_environment"
    t.string "switching_costs"
    t.integer "industry_volatility"
    t.integer "tech_disruption_risk"
    t.integer "personal_upside_score"
    t.integer "career_risk_score"
    t.bigint "user_id", null: false
    t.index "lower((name)::text)", name: "index_companies_on_lower_name", unique: true
    t.index ["funding_stage"], name: "index_companies_on_funding_stage"
    t.index ["growth_signal"], name: "index_companies_on_growth_signal"
    t.index ["industry"], name: "index_companies_on_industry"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "email"
    t.string "phone"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "linkedin"
    t.text "about"
    t.text "notes"
    t.index ["company_id"], name: "index_contacts_on_company_id"
  end

  create_table "core_narratives", force: :cascade do |t|
    t.string "narrative_type", null: false
    t.string "version"
    t.string "role_target"
    t.text "content", null: false
    t.date "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["narrative_type", "role_target"], name: "index_core_narratives_on_narrative_type_and_role_target"
    t.index ["narrative_type"], name: "index_core_narratives_on_narrative_type"
    t.index ["user_id"], name: "index_core_narratives_on_user_id"
  end

  create_table "interview_sessions", force: :cascade do |t|
    t.bigint "opportunity_id", null: false
    t.string "stage", null: false
    t.datetime "scheduled_at", null: false
    t.integer "confidence_score"
    t.string "overall_signal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.integer "duration_minutes"
    t.string "format"
    t.string "status"
    t.text "questions_they_asked"
    t.text "questions_i_asked"
    t.text "follow_ups"
    t.text "next_steps"
    t.index ["contact_id"], name: "index_interview_sessions_on_contact_id"
    t.index ["opportunity_id", "scheduled_at"], name: "index_interview_sessions_on_opportunity_id_and_scheduled_at"
    t.index ["opportunity_id"], name: "index_interview_sessions_on_opportunity_id"
    t.index ["overall_signal"], name: "index_interview_sessions_on_overall_signal"
    t.index ["scheduled_at"], name: "index_interview_sessions_on_scheduled_at"
    t.index ["stage"], name: "index_interview_sessions_on_stage"
    t.index ["status"], name: "index_interview_sessions_on_status"
  end

  create_table "opportunities", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "position_title"
    t.date "application_date"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "remote"
    t.string "tech_stack"
    t.string "source"
    t.string "salary_range"
    t.string "chatgpt_match"
    t.string "jobright_match"
    t.string "linkedin_match"
    t.string "listing_url"
    t.text "other_tech_stack"
    t.string "role_type", default: "software_engineer", null: false
    t.jsonb "role_metadata", default: {}, null: false
    t.decimal "fit_score", precision: 3, scale: 2
    t.integer "income_range_low"
    t.integer "income_range_high"
    t.string "retirement_plan_type"
    t.string "remote_type"
    t.integer "company_size"
    t.string "risk_level"
    t.integer "trajectory_score"
    t.integer "strategic_value"
    t.integer "bus_factor"
    t.index ["company_id"], name: "index_opportunities_on_company_id"
    t.index ["fit_score"], name: "index_opportunities_on_fit_score"
    t.index ["remote_type"], name: "index_opportunities_on_remote_type"
    t.index ["risk_level"], name: "index_opportunities_on_risk_level"
    t.index ["role_metadata"], name: "index_opportunities_on_role_metadata", using: :gin
    t.index ["role_type"], name: "index_opportunities_on_role_type"
  end

  create_table "opportunity_technologies", force: :cascade do |t|
    t.bigint "opportunity_id", null: false
    t.bigint "technology_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opportunity_id", "technology_id"], name: "index_opp_tech_on_opp_and_tech", unique: true
    t.index ["opportunity_id"], name: "index_opportunity_technologies_on_opportunity_id"
    t.index ["technology_id"], name: "index_opportunity_technologies_on_technology_id"
  end

  create_table "resource_guide_questions", force: :cascade do |t|
    t.string "guide_type", null: false
    t.string "section_title"
    t.text "question"
    t.text "meaning"
    t.text "response_approach"
    t.text "example_response"
    t.text "pitfall"
    t.text "why_this_is_strong"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["guide_type"], name: "index_resource_guide_questions_on_guide_type"
    t.index ["user_id"], name: "index_resource_guide_questions_on_user_id"
  end

  create_table "resource_sheets", force: :cascade do |t|
    t.string "title", null: false
    t.string "resource_type", default: "interview_prep", null: false
    t.string "role_type"
    t.bigint "company_id"
    t.bigint "opportunity_id"
    t.string "version_label"
    t.boolean "active", default: true, null: false
    t.text "about_me_content"
    t.text "about_me_bullets"
    t.text "why_company_content"
    t.text "why_company_bullets"
    t.text "why_me_content"
    t.text "why_me_bullets"
    t.text "salary_content"
    t.text "salary_bullets"
    t.text "notes_content"
    t.text "notes_bullets"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["active"], name: "index_resource_sheets_on_active"
    t.index ["company_id"], name: "index_resource_sheets_on_company_id"
    t.index ["opportunity_id"], name: "index_resource_sheets_on_opportunity_id"
    t.index ["resource_type"], name: "index_resource_sheets_on_resource_type"
    t.index ["role_type"], name: "index_resource_sheets_on_role_type"
    t.index ["user_id"], name: "index_resource_sheets_on_user_id"
  end

  create_table "star_stories", force: :cascade do |t|
    t.string "title", null: false
    t.text "situation"
    t.text "task"
    t.text "action"
    t.text "result"
    t.string "skills", default: [], array: true
    t.string "category"
    t.integer "strength_score"
    t.integer "times_used", default: 0
    t.date "last_used_at"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category"], name: "index_star_stories_on_category"
    t.index ["skills"], name: "index_star_stories_on_skills", using: :gin
    t.index ["strength_score"], name: "index_star_stories_on_strength_score"
    t.index ["user_id"], name: "index_star_stories_on_user_id"
  end

  create_table "star_story_opportunities", force: :cascade do |t|
    t.bigint "star_story_id", null: false
    t.bigint "opportunity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opportunity_id"], name: "index_star_story_opportunities_on_opportunity_id"
    t.index ["star_story_id"], name: "index_star_story_opportunities_on_star_story_id"
  end

  create_table "technologies", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_technologies_on_category"
    t.index ["name"], name: "index_technologies_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "demo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demo"], name: "index_users_on_demo"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "companies", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "core_narratives", "users"
  add_foreign_key "interview_sessions", "contacts"
  add_foreign_key "interview_sessions", "opportunities"
  add_foreign_key "opportunities", "companies"
  add_foreign_key "opportunity_technologies", "opportunities"
  add_foreign_key "opportunity_technologies", "technologies"
  add_foreign_key "resource_guide_questions", "users"
  add_foreign_key "resource_sheets", "companies"
  add_foreign_key "resource_sheets", "opportunities"
  add_foreign_key "resource_sheets", "users"
  add_foreign_key "star_stories", "users"
  add_foreign_key "star_story_opportunities", "opportunities"
  add_foreign_key "star_story_opportunities", "star_stories"
end
