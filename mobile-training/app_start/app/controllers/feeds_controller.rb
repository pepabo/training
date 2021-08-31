class FeedsController < ApplicationController
  before_action :logged_in_user

  def index
    respond_to do |format|
      format.json do
        @feeds = current_user.feed.paginate(page: params[:page])
      end
    end
  end
end
