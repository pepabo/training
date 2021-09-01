class Api::V1::FeedsController < Api::V1::ApplicationController
  before_action -> { doorkeeper_authorize! :read }

  def index
    @feeds = current_user.feed.paginate(page: params[:page])
  end
end
