class CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show edit update destroy ]

  # GET /companies or /companies.json
  def index
    @companies = current_or_demo_user.companies.includes(:opportunities)
    @technologies = Technology.order(:name)

    # Filter by company name search
    if params[:company_query].present?
      company_query = "%#{params[:company_query].strip}%"
      @companies = @companies.where("companies.name ILIKE ?", company_query)
    end

    # Filter by technology if provided
    if params[:technology].present?
      tech = Technology.find_by(name: params[:technology])
      if tech
        @companies = @companies.joins(opportunities: :technologies)
                              .where(technologies: { id: tech.id }).distinct
      end
      @selected_technology = params[:technology]
    end

    # Always include technologies for display
    @companies = @companies.includes(opportunities: :technologies)

    # Skip sorting for tech_stack since it's aggregated data, but allow other columns
    if params[:sort].present? && params[:sort] != "tech_stack"
      direction = params[:direction] == "desc" ? "desc" : "asc"
      @companies = @companies.order("#{params[:sort]} #{direction}")
    else
      @companies = @companies.order(:name)
    end
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/new
  def new
    @company = current_or_demo_user.companies.new
  end

  # GET /companies/1/edit
  def edit
  end

  # POST /companies or /companies.json
  def create
    @company = current_or_demo_user.companies.new(company_params)

    # Handle known_tech_stack_list from checkboxes
    if params[:company] && params[:company][:known_tech_stack_list].present?
      techs = params[:company][:known_tech_stack_list].reject(&:blank?)
      @company.known_tech_stack = techs.join(", ")
    end

    respond_to do |format|
      if @company.save
        format.html { redirect_to @company, notice: "Company was successfully created." }
        format.json { render :show, status: :created, location: @company }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    # Handle known_tech_stack_list from checkboxes
    if params[:company] && params[:company][:known_tech_stack_list].present?
      techs = params[:company][:known_tech_stack_list].reject(&:blank?)
      params[:company][:known_tech_stack] = techs.join(", ")
    end

    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: "Company was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /companies/1 or /companies/1.json
  def destroy
    @company.destroy!

    respond_to do |format|
      format.html { redirect_to companies_path, notice: "Company was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = current_or_demo_user.companies.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: [
        :name, :industry, :company_type, :location, :size, :website, :linkedin, :known_tech_stack,
        :primary_product, :revenue_model, :funding_stage, :estimated_revenue, :estimated_employees,
        :growth_signal, :product_maturity, :engineering_maturity, :process_maturity,
        :market_position, :competitor_tier, :brand_signal_strength, :market_size_estimate
      ])
    end
end
