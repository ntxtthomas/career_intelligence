class ResourceGuideQuestionsController < ApplicationController
  before_action :set_resource_guide_question, only: %i[edit update destroy]

  def new
    @resource_guide_question = current_or_demo_user.resource_guide_questions.new(guide_type: params[:guide_type])
  end

  def create
    @resource_guide_question = current_or_demo_user.resource_guide_questions.new(resource_guide_question_params)

    if @resource_guide_question.save
      redirect_to guide_path_for(@resource_guide_question.guide_type), notice: "Guide question was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @resource_guide_question.update(resource_guide_question_params)
      redirect_to guide_path_for(@resource_guide_question.guide_type), notice: "Guide question was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    guide_type = @resource_guide_question.guide_type
    @resource_guide_question.destroy
    redirect_to guide_path_for(guide_type), notice: "Guide question was successfully deleted."
  end

  private

  def set_resource_guide_question
    @resource_guide_question = current_or_demo_user.resource_guide_questions.find(params.expect(:id))
  end

  def resource_guide_question_params
    params.expect(resource_guide_question: [
      :guide_type,
      :section_title,
      :question,
      :meaning,
      :response_approach,
      :example_response,
      :pitfall,
      :why_this_is_strong
    ])
  end

  def guide_path_for(guide_type)
    case guide_type
    when "behavioral"
      behavioral_guide_path
    when "technical"
      technical_guide_path
    when "interviewer_questions"
      interviewer_questions_guide_path
    when "acquired_questions"
      acquired_questions_guide_path
    else
      resource_sheets_path
    end
  end
end
