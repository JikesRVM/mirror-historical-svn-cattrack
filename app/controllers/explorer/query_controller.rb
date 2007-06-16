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
class Explorer::QueryController < Explorer::BaseController
  verify :method => :get, :only => [:list], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:destroy], :redirect_to => :access_denied_url

  def list
    @query_pages, @queries = paginate(Olap::Query::Query, :per_page => 10, :order => 'name')
  end

  def new
    @query = Olap::Query::Query.new(params[:query])
    if request.post?
      if @query.save
        flash[:notice] = "Query named '#{@query.name}' was successfully created."
        redirect_to(:action => 'list')
        AuditLog.log('query.created', @query)
        return
      end
    end
    populate_values
  end

  def edit
    @query = Olap::Query::Query.find(params[:id])
    @query.attributes = params[:query]
    if request.post?
      if @query.save
        flash[:notice] = "Query named '#{@query.name}' was successfully saved."
        redirect_to(:action => 'list')
        AuditLog.log('query.updated', @query)
        return
      end
    end
    populate_values
  end

  def destroy
    query = Olap::Query::Query.find(params[:id])
    query.destroy
    flash[:notice] = "Query named '#{query.name}' was successfully deleted."
    AuditLog.log('query.deleted', query)
    redirect_to(:action => 'list')
  end

  private

  def populate_values
    @filters = Olap::Query::Filter.find(:all, :order => 'name')
    @measures = Olap::Query::Measure.find(:all, :order => 'name')
  end
end
