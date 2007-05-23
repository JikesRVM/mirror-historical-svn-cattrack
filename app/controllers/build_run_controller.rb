class BuildRunController < ApplicationController
  verify :method => :get, :only => [:show, :show_output], :redirect_to => {:action => :index}

  def show
    @record = BuildRun.find(params[:id])
  end

  def show_output
    @record = BuildRun.find(params[:id])
    headers['Content-Type'] = 'text/plain'
    render(:text => @record.output, :layout => false)
  end
end
