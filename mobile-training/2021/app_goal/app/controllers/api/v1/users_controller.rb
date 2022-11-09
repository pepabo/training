class Api::V1::UsersController < Api::V1::ApplicationController
  before_action -> { doorkeeper_authorize! :read }

  def index
    @users = User.preload(:microposts).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def self
    @current_user = current_user
  end
end
