class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    respond_to do |format|
      if @micropost.save
        format.html do
          flash[:success] = "Micropost created!"
          redirect_to root_url
        end
        format.json { render :show, status: :created }
      else
        format.html do
          @feed_items = current_user.feed.paginate(page: params[:page])
          render 'static_pages/home'
        end
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @micropost.destroy
    respond_to do |format|
      format.html do
        flash[:success] = "Micropost deleted"
        redirect_to request.referrer || root_url
      end
      format.json { head :no_content }
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
