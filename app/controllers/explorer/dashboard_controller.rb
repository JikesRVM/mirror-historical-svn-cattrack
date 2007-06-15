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
class Explorer::DashboardController < Explorer::BaseController
  def index
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
end
