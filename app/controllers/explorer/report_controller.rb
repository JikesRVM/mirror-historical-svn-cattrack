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
  #verify :method => :get, :only => [:list], :redirect_to => :access_denied_url

  def list
    Olap::Query::Filter::AutoFields.each do |f|
      value = f.dimension.attribute_values(f.name.to_s)
      instance_variable_set("@#{f.key.to_s.pluralize}", value)
    end
    @data_presentations = DataPresentation.find(:all, :order => 'name')
    data_view = DataView.new
    data_view.filter = Olap::Query::Filter.new(params[:filter])
    data_view.filter.name = '*'
    data_view.filter.description = ''
    data_view.summarizer = Summarizer.new(params[:summarizer])
    data_view.summarizer.name = '*'
    data_view.summarizer.description = ''

    @filter = data_view.filter
    @summarizer = data_view.summarizer

    if request.post?
      @data_presentation = DataPresentation.find(params[:data_presentation])
      if @data_presentation and @summarizer.valid? and @filter.valid?
        @results = data_view.perform_search

      end
    end
  end
end
