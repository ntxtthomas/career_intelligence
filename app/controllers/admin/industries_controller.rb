module Admin
  class IndustriesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin_user
    before_action :set_industry, only: %i[show edit update destroy]

    def index
      roots = Industry.roots.includes(:children).to_a
      @company_counts = Company.group(:industry_id).count
      @root_totals = roots.to_h { |root| [ root.id, [ root, *root.children ].sum { |industry| @company_counts[industry.id].to_i } ] }
      @industries = sort_roots(roots)
    end

    def show
    end

    def new
      @industry = Industry.new(parent_id: params[:parent_id])
    end

    def edit
    end

    def create
      @industry = Industry.new(industry_params)

      if @industry.save
        redirect_to admin_industry_path(@industry), notice: "#{@industry.full_name} was created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @industry.update(industry_params)
        redirect_to admin_industry_path(@industry), notice: "#{@industry.full_name} was updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @industry.destroy
        redirect_to admin_industries_path, notice: "#{@industry.full_name} was deleted.", status: :see_other
      else
        redirect_to admin_industry_path(@industry), alert: @industry.errors.full_messages.to_sentence, status: :see_other
      end
    end

    private

    def require_admin_user
      return if admin_user?

      redirect_to dashboard_path, alert: "Admin access only."
    end

    def set_industry
      @industry = Industry.find(params.expect(:id))
    end

    def industry_params
      params.expect(industry: [ :name, :parent_id, :domain_match ])
    end

    # Only top-level industries are sortable; segments always stay under their parent, ordered by name.
    def sort_roots(roots)
      key = case params[:sort]
      when "domain_match" then ->(industry) { Industry::DOMAIN_MATCHES.index(industry.domain_match) || -1 }
      when "companies" then ->(industry) { @root_totals[industry.id] }
      else ->(industry) { industry.name.downcase }
      end

      sorted = roots.sort_by { |industry| [ key.call(industry), industry.name.downcase ] }
      params[:direction] == "desc" ? sorted.reverse : sorted
    end
  end
end
