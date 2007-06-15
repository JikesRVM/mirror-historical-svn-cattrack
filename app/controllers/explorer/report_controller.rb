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
class Explorer::ReportController < Explorer::BaseController
  verify :method => :get, :only => [:list], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:destroy], :redirect_to => :access_denied_url

  def list
    @report_pages, @reports = paginate(Olap::Query::Report, :per_page => 10, :order => 'name')
  end

  def new
    @report = Olap::Query::Report.new(params[:report])
    if request.post?
      if @report.save
        flash[:notice] = "Report named '#{@report.name}' was successfully created."
        redirect_to(:action => 'list')
        return
      end
    end
    populate_query_values
  end

  def edit
    @report = Olap::Query::Report.find(params[:id])
    @report.attributes = params[:report]
    if request.post?
      if @report.save
        flash[:notice] = "Report named '#{@report.name}' was successfully saved."
        redirect_to(:action => 'list')
        return
      end
    end
    populate_query_values
  end

  def destroy
    report = Olap::Query::Report.find(params[:id])
    report.destroy
    flash[:notice] = "Report named '#{report.name}' was successfully deleted."
    redirect_to(:action => 'list')
  end

  private

  def populate_query_values
    @queries = Olap::Query::Query.find(:all, :order => 'name')
    @presentations = Olap::Query::Presentation.find(:all, :order => 'name')
  end
end
