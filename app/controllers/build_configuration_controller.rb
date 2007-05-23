class BuildConfigurationController < ApplicationController
  verify :method => :get, :only => [:show], :redirect_to => {:action => :index}

  def show
    @record = BuildConfiguration.find(params[:id])
  end
end
