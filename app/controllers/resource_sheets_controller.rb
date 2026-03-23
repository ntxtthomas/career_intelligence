class ResourceSheetsController < ApplicationController
  before_action :set_resource_sheet, only: %i[show edit update destroy]
  before_action :load_form_collections, only: %i[new create edit update]

  def index
    @resource_sheets = ResourceSheet.includes(:company, :opportunity)

    if params[:sort].present?
      sort_column = params[:sort]
      sort_direction = params[:direction] == "desc" ? "desc" : "asc"
      allowed_columns = %w[title resource_type role_type version_label active updated_at]

      if allowed_columns.include?(sort_column)
        @resource_sheets = @resource_sheets.order("#{sort_column} #{sort_direction}")
      elsif sort_column == "company"
        @resource_sheets = @resource_sheets.left_joins(:company).order("companies.name #{sort_direction} NULLS LAST")
      elsif sort_column == "opportunity"
        @resource_sheets = @resource_sheets.left_joins(:opportunity).order("opportunities.position_title #{sort_direction} NULLS LAST")
      else
        @resource_sheets = @resource_sheets.order(updated_at: :desc)
      end
    else
      @resource_sheets = @resource_sheets.order(updated_at: :desc)
    end
  end

  def show
  end

  def new
    @resource_sheet = ResourceSheet.new(resource_type: :interview_prep)
  end

  def edit
  end

  def create
    @resource_sheet = ResourceSheet.new(resource_sheet_params)

    if @resource_sheet.save
      redirect_to @resource_sheet, notice: "Resource was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @resource_sheet.update(resource_sheet_params)
      redirect_to @resource_sheet, notice: "Resource was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource_sheet.destroy
    redirect_to resource_sheets_path, notice: "Resource was successfully deleted."
  end

  def generate_from_opportunity
    opportunity = Opportunity.includes(:company).find_by(id: params[:opportunity_id])

    unless opportunity
      redirect_to opportunities_path, alert: "Opportunity not found."
      return
    end

    resource_sheet = ResourceSheet.create!(
      title: "#{opportunity.position_title} Interview Prep",
      resource_type: :interview_prep,
      role_type: opportunity.role_type,
      company: opportunity.company,
      opportunity: opportunity,
      version_label: "v1",
      active: true
    )

    redirect_to edit_resource_sheet_path(resource_sheet), notice: "Resource draft generated from opportunity."
  end

  def behavioral_guide
    @additional_questions = ResourceGuideQuestion.for_guide(:behavioral).ordered
  end

  def technical_guide
    @additional_questions = ResourceGuideQuestion.for_guide(:technical).ordered
  end

  def interviewer_questions_guide
    @additional_questions = ResourceGuideQuestion.for_guide(:interviewer_questions).ordered
  end

  def acquired_questions_guide
    @additional_questions = ResourceGuideQuestion.for_guide(:acquired_questions).ordered
  end

  private

  def set_resource_sheet
    @resource_sheet = ResourceSheet.find(params.expect(:id))
  end

  def load_form_collections
    @companies = Company.order(:name)
    @opportunities = Opportunity.includes(:company).references(:company).order("companies.name ASC, opportunities.position_title ASC")
    @role_type_options = Opportunity::ROLE_TYPES.map { |key, value| [ value, key ] }
    @resource_type_options = ResourceSheet::RESOURCE_TYPES.map { |key, label| [ label, key ] }

    @opportunity_select_options = @opportunities.map do |opportunity|
      [ "#{opportunity.company.name} — #{opportunity.position_title}", opportunity.id ]
    end

    @opportunity_scope_data = @opportunities.map do |opportunity|
      {
        id: opportunity.id,
        company_id: opportunity.company_id,
        label: "#{opportunity.company.name} — #{opportunity.position_title}"
      }
    end
  end

  def resource_sheet_params
    params.expect(resource_sheet: [
      :title,
      :resource_type,
      :role_type,
      :company_id,
      :opportunity_id,
      :version_label,
      :active,
      :about_me_content,
      :about_me_bullets,
      :why_company_content,
      :why_company_bullets,
      :why_me_content,
      :why_me_bullets,
      :salary_content,
      :salary_bullets,
      :notes_content,
      :notes_bullets
    ])
  end
end
