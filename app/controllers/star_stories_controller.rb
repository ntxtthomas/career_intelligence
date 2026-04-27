class StarStoriesController < ApplicationController
  before_action :set_star_story, only: [ :show, :edit, :update, :destroy ]

  def index
    @star_stories = current_or_demo_user.star_stories.order(created_at: :desc)

    respond_to do |format|
      format.html
      format.csv do
        exporter = StarStoriesCsvExporter.new(@star_stories)
        send_data exporter.generate,
                  filename: "star_stories_#{Date.current.strftime('%Y-%m-%d')}.csv",
                  type: "text/csv"
      end
    end
  end

  def new
    @star_story = current_or_demo_user.star_stories.new
  end

  def create
    params_hash = star_story_params
    process_skills_param(params_hash)

    @star_story = current_or_demo_user.star_stories.new(params_hash)

    if @star_story.save
      redirect_to @star_story, notice: "STAR story was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params_hash = star_story_params
    process_skills_param(params_hash)

    if @star_story.update(params_hash)
      redirect_to @star_story, notice: "STAR story was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @star_story.destroy
    redirect_to star_stories_url, notice: "STAR story was successfully deleted."
  end

  def show
  end

  private

  def set_star_story
    @star_story = current_or_demo_user.star_stories.find(params[:id])
  end

  def star_story_params
    params.require(:star_story).permit(
      :title, :situation, :task, :action, :result, :category,
      :strength_score, :notes, :skills, opportunity_ids: []
    )
  end

  def process_skills_param(params_hash)
    if params_hash[:skills].is_a?(String)
      params_hash[:skills] = params_hash[:skills].split("\n").map(&:strip).reject(&:blank?)
    end
  end
end
