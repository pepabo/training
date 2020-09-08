class FeedsController < ApplicationController
  before_action :logged_in_user

  def index
    @feeds = current_user.feed.paginate(page: params[:page])
  end
end
