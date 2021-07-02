class StaticPagesController < ApplicationController
  before_action :logged_in_user, only: [:me]

  def home
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end

  def me
    respond_to do |format|
      format.json {}
    end
  end
end
