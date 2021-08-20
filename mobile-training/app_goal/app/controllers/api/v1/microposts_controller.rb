class Api::V1::MicropostsController < Api::V1::ApplicationController
  before_action -> { doorkeeper_authorize! :read }
  before_action -> { doorkeeper_authorize! :write }

  def create
    micropost = current_user.microposts.build(content: params[:content])
    if micropost.save
      head :created
    else
      render json: micropost.errors, status: :unprocessable_entity
    end
  end

  def destroy
    micropost = current_user.microposts.find_by(id: params[:id])
    return head :not_found unless micropost

    micropost.destroy
    head :no_content
  end
end
