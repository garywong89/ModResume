class VolunteeringsController < ApplicationController

  def new
    @user = current_user
    @volunteering = Volunteering.new
    @description  = Description.new
    render partial: 'form'
  end

  def edit
    @user = current_user
    @volunteering = Volunteering.find(params[:id])
    render partial: 'form'
  end



  def create
    @user = current_user
    pass_params = volunteering_params
    descriptions = pass_params.delete(:details) || []
    @volunteering = current_user.volunteerings.new(pass_params)
    if @volunteering.save
      @user.tags << @volunteering.tags
      flash[:asset_saved] = "Asset Saved. Add another?"
      addDescriptions(@volunteering, descriptions)
      respond_to do |format|
        format.json do
          render :json => {taggable_type: "Volunteering", taggable_id: @volunteering.id}
        end
        format.html do
          redirect_to new_user_asset_path
        end
      end
    else
      flash.now[:danger] = @volunteering.errors.full_messages
    end

  end

  def update
    @volunteering = Volunteering.find(params[:id])
    @volunteering.descriptions.delete_all
    pass_params = volunteering_params
    detail_attributes = pass_params.delete(:details) || []
    @volunteering.update(pass_params)
    if @volunteering.save
        addDescriptions(@volunteering, detail_attributes)
    else
      flash.now[:danger] = @volunteering.errors.full_messages
    end
    render partial: 'show', locals: {asset: @volunteering, asset_type: "volunteerings", asset_descriptions: @volunteering.descriptions}
  end

  def destroy
    @volunteering = Volunteering.find(params[:id])
    @volunteering.destroy
    render nothing: true, status: 200, content_type: "text/html"
  end

  private

    def volunteering_params
      params.require(:volunteering).permit(:organization, :title, :begin_date, :end_date, :location, :tags_string, :details =>[:detail], :descriptions_attributes => [:detail])
    end

end
