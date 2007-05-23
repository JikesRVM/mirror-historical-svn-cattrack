class BuildTargetController < ApplicationController
  verify :method => :get, :only => [:show], :redirect_to => {:action => :index}

  def show
    @record = BuildTarget.find(params[:id])
  end
end
