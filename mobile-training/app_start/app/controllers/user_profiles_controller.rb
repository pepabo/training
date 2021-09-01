class UserProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])

    respond_to do |format|
      format.html { render "static_pages/home" }
      format.json {}
    end
  end
end
