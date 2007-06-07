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
class FilterController < ApplicationController
  verify :method => :get, :only => [:list], :redirect_to => {:action => :index}
  verify :method => :post, :only => [:destroy], :redirect_to => {:action => :index}

  def list
    @filter_pages, @filters = paginate(:filters, :per_page => 10, :order => 'name')
  end

  def edit
    @filter = params[:id] ? Filter.find(params[:id]) : Filter.new
    @filter.attributes = params[:filter]
    if request.post?
      if @filter.save
        flash[:notice] = "Filter named '#{@filter.name}' was successfully saved."
        redirect_to(:action => 'list')
      end
    end
    Filter::AutoFields.each do |f|
      value = select_values(f.dimension, f.name)
      instance_variable_set("@#{f.key.to_s.pluralize}", value)
    end
  end

  def destroy
    filter = Filter.find(params[:id])
    filter.destroy
    flash[:notice] = "Filter named '#{filter.name}' was successfully deleted."
    redirect_to(:action => 'list')
  end

  protected

  def protect?
    true
  end

  private

  def select_values(type, key)
    sql = "SELECT DISTINCT #{key} FROM #{type.table_name} ORDER BY #{key}"
    type.connection.select_values(sql)
  end
end
