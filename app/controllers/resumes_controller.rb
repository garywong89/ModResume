class ResumesController < ApplicationController
  before_action :set_resume, only: [:edit, :show, :update, :destroy]

  def index
      @resumes = Resume.where(user_id: current_user.id).order(:updated_at)
      @user = current_user
      @new_resume = Resume.new
  end

  def show
    session[:edit_asset] = false
    @tags = Tag.all
    @resume = Resume.find(params[:id])
    @assets = {}
    @asset_types = asset_types
    session[:new_resume_id] = @resume.id

    @asset_types.each do |asset_type|
      @assets["#{asset_type}"] = []
      resume_assets = ResumeAsset.where("resume_id=? AND buildable_type=?", params[:id], asset_type.capitalize.singularize)
      resume_assets.each do |resume_asset|
        @assets["#{asset_type}"] << resume_asset
      end
    end
  end

  def new
    @user = current_user
    @tags = current_user.tags
    @new_resume = Resume.new()
    render partial: 'form'
  end

  def create
    pass_params = resume_params
    @new_resume = Resume.new(pass_params)
    if @new_resume.save
      session[:new_resume_id] = @new_resume.id
      redirect_to user_assets_path
    end
  end

  # edit html text
  def edit
    session[:new_resume_id] = Resume.find(params[:id]).id
    redirect_to user_assets_path
    # @resume = Resume.find(params[:id])
  end

  def save_document_data
    @resume = Resume.find(params[:id])
    @resume.document_data = params[:document_data]
    @resume.save
    redirect_to user_resume_fine_tune_path
  end

  def fine_tune
    @resume = Resume.find(params[:id])
    render partial: 'fine_tune', resume: @resume
  end

  def update
    asset_type = params[:data_asset_type].singularize.capitalize
    resume = Resume.find(params[:id])
    asset_resumes = asset_type.constantize.find(params[:data_asset_id]).resumes
    selected_descriptions = []
    selected_descriptions.push params[:selected_descriptions] if params[:selected_descriptions]
    if asset_resumes.include? resume
      asset_resumes.delete resume
      update_status = "removed"
    else
      asset_resumes << resume
      update_status = "added"
      resume_asset = resume.resume_assets.find_by(buildable_type: asset_type, buildable_id: params[:data_asset_id])
      selected_descriptions.each do |desc|
        resume_asset.descriptions << Description.find(desc)
      end
      resume_asset.save
    end

    respond_to do |format|
      format.json { render json: {resume: resume, update_status: update_status}}
      format.html { p "RETURNING HTML" }

    end
  end

  def destroy
    @resume.destroy
    redirect_to user_resumes_path(params[:user_id])
  end

private
  def set_resume
    @resume = Resume.find(params[:id])
  end

  def resume_params
    params.require(:resume).permit(:user_id, :target_job, :document_data)
  end

end
