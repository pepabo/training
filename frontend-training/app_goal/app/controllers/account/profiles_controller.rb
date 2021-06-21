module Account
  class ProfilesController < ApplicationController
    before_action :logged_in_user

    def index
      respond_to do |format|
        format.json {}
      end
    end
  end
end
