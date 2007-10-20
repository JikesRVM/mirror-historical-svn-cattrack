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
class Results::HostController < Results::BaseController
  verify :method => :get, :redirect_to => :access_denied_url

  def show
    @host = host
    @variants = ActiveRecord::Base.connection.select_values(<<SQL)
SELECT DISTINCT variant FROM test_runs WHERE host_id = #{@host.id} ORDER BY variant
SQL
  end

  def list
    @record_pages, @records = paginate(Tdm::Host, :per_page => 20, :order => 'name')
  end
end
