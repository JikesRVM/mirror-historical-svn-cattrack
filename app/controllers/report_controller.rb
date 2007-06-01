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
class ReportController < ApplicationController
  verify :method => :get, :only => [:list], :redirect_to => {:action => :index}

  def list
    Search::AutoFields.each do |f|
      value = select_values(f.dimension, f.name)
      instance_variable_set("@#{f.key.to_s.pluralize}", value)
    end

    @search = Search.new(params[:search])
    @results = @search.perform_search
  end

  private

  def select_values(type, key)
    sql = "SELECT DISTINCT #{key} FROM #{type.table_name} ORDER BY #{key}"
    type.connection.select_values(sql)
  end
end
