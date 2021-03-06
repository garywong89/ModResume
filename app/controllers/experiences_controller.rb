class ExperiencesController < ApplicationController


  def show
    @experience = Experience.find(params[:id])
    # render :json @experience.to_json
  end

  def new
    @user = current_user
    @experience = Experience.new
    @description  = Description.new
    @tags_list = []
    render partial: 'form'
  end

  def edit
    @user = current_user
    @experience = Experience.find(params[:id])
    @tags_list = @experience.tags.order("name").map{|t| t.name}.join(", ")
    render partial: 'form'
  end



  def create
    @user = current_user
    pass_params = experience_params
    descriptions = pass_params.delete(:details) || []
    @experience = current_user.experiences.new(pass_params)
    if @experience.save
      @user.tags << @experience.tags
      addDescriptions(@experience, descriptions)
      flash[:asset_saved] = "Asset Saved. Add another?"
      respond_to do |format|
        format.json do
          render :json => {taggable_type: "Experience", taggable_id: @experience.id}
        end
        format.html do
          redirect_to new_user_asset_path
        end
      end
    else
      flash.now[:notice] = @experience.errors.full_messages
    end
  end

  def update
    @experience = Experience.find(params[:id])
    @experience.descriptions.delete_all
    pass_params = experience_params
    detail_attributes = pass_params.delete(:details) || []
    @experience.update(pass_params)
    if @experience.save
        addDescriptions(@experience, detail_attributes)
    else
      flash.now[:danger] = @experience.errors.full_messages
      render :edit
    end
    render partial: 'show', locals: {asset: @experience, asset_type: "experiences", asset_descriptions: @experience.descriptions}
  end

  def destroy
    @experience = Experience.find(params[:id])
    @experience.destroy
    render nothing: true, status: 200, content_type: "text/html"
  end

private

    def experience_params
      params.require(:experience).permit(:company, :title, :begin_date, :end_date, :location, :tags_string, :details =>[:detail], :descriptions_attributes => [:detail])
    end

end
