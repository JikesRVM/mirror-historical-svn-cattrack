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
  verify :method => :get, :only => [:public_list, :show, :list], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:destroy], :redirect_to => :access_denied_url

  def adhoc
    query = Olap::Query::Query.new(params[:query])
    query.filter = Olap::Query::Filter.new(params[:filter])
    query.filter.name = '*'
    query.filter.description = ''
    query.name = '*'
    query.description = ''

    @measure = query.measure
    @filter = query.filter
    @query = query

    if request.post?
      @presentation = Olap::Query::Presentation.find(params[:presentation])
      if @presentation and query.measure.valid? and query.filter.valid?
        @results = query.perform_search
      end
    else
      # Assume get and populate with reasonable defaults
      @query.measure = Olap::Query::Measure.find_by_name('Success Rate')
      @query.primary_dimension = 'test_configuration_name'
      @query.secondary_dimension = 'revision_revision'
    end

    @presentations = Olap::Query::Presentation.find(:all, :order => 'name')
    @measures = Olap::Query::Measure.find(:all, :order => 'name')
    @filters = Olap::Query::Filter.find(:all, :order => 'name')
    Olap::Query::Filter::AutoFields.each do |f|
      value = f.dimension.attribute_values(f.name.to_s)
      instance_variable_set("@#{f.key.to_s.pluralize}", value)
    end
  end

  def public_list
    list
  end

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

  def show
    @report = Olap::Query::Report.find_by_key(params[:key])
    raise CatTrack::SecurityError unless @report
    @results = @report.query.perform_search
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

  protected
  def protect?
    not ['adhoc', 'public_list', 'show'].include?( action_name )
  end

  def menu_name
    (is_authenticated? and protect?) ? '/explorer/menu' : nil
  end

  private

  def populate_query_values
    @queries = Olap::Query::Query.find(:all, :order => 'name')
    @presentations = Olap::Query::Presentation.find(:all, :order => 'name')
  end
end
