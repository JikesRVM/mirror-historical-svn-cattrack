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
class Explorer::FilterController < Explorer::BaseController
  verify :method => :get, :only => [:list], :redirect_to => :access_denied_url
  verify :method => :post, :only => [:destroy], :redirect_to => :access_denied_url

  def list
    @filter_pages, @filters = paginate(Olap::Query::Filter, :per_page => 10, :order => 'name')
  end

  def edit
    @filter = params[:id] ? Olap::Query::Filter.find(params[:id]) : Olap::Query::Filter.new
    @filter.attributes = params[:filter]
    if request.post?
      if @filter.save
        flash[:notice] = "Filter named '#{@filter.name}' was successfully saved."
        redirect_to(:action => 'list')
      end
    end
    Olap::Query::Filter::AutoFields.each do |f|
      value = f.dimension.attribute_values(f.name.to_s)
      instance_variable_set("@#{f.key.to_s.pluralize}", value)
    end
  end

  def destroy
    filter = Olap::Query::Filter.find(params[:id])
    filter.destroy
    flash[:notice] = "Filter named '#{filter.name}' was successfully deleted."
    redirect_to(:action => 'list')
  end
end
