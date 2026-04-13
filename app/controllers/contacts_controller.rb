class ContactsController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy ]

  # GET /contacts or /contacts.json
  def index
    @contacts = current_or_demo_user.contacts.includes(:company)

    # Handle sorting
    if params[:sort].present?
      sort_column = params[:sort]
      sort_direction = params[:direction] == "desc" ? "desc" : "asc"

      # Validate sort column to prevent SQL injection
      allowed_columns = %w[name title email phone created_at]
      if allowed_columns.include?(sort_column)
        @contacts = @contacts.order("#{sort_column} #{sort_direction}")
      elsif sort_column == "company"
        @contacts = @contacts.joins(:company).order("companies.name #{sort_direction}")
      end
    else
      @contacts = @contacts.order(:name)
    end
  end

  # GET /contacts/1 or /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
    @companies = current_or_demo_user.companies.order(:name)
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts or /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: "Contact was successfully created." }
        format.json { render :show, status: :created, location: @contact }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1 or /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: "Contact was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @contact }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1 or /contacts/1.json
  def destroy
    @contact.destroy!

    respond_to do |format|
      format.html { redirect_to contacts_path, notice: "Contact was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = current_or_demo_user.contacts.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def contact_params
      params.expect(contact: [ :name, :title, :email, :phone, :linkedin, :about, :notes, :company_id ])
    end
end
