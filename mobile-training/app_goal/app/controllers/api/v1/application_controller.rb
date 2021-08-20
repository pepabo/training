class Api::V1::ApplicationController < ActionController::Base
  private
    def current_user
      @current_user = User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
