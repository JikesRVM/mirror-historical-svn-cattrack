#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Common Public License (CPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
class Explorer::SummarizerController < Explorer::BaseController
  verify :method => :get, :only => [:list], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:destroy], :redirect_to => {:action => :index}

  def list
    @summarizer_pages, @summarizers = paginate(:summarizers, :per_page => 10, :order => 'name')
  end

  def edit
    @summarizer = params[:id] ? Summarizer.find(params[:id]) : Summarizer.new
    @summarizer.attributes = params[:summarizer]
    if request.post?
      if @summarizer.save
        flash[:notice] = "Summarizer named '#{@summarizer.name}' was successfully saved."
        redirect_to(:action => 'list')
      end
    end
  end

  def destroy
    summarizer = Summarizer.find(params[:id])
    summarizer.destroy
    flash[:notice] = "Summarizer named '#{summarizer.name}' was successfully deleted."
    redirect_to(:action => 'list')
  end
end
