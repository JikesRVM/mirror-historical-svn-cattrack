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
require File.dirname(__FILE__) + '/../test_helper'

class ReportResultDataTest < Test::Unit::TestCase
  def test_basic_operation
    row = SearchField.new(BuildConfigurationDimension, :name)
    column = SearchField.new(TimeDimension, :da_of_week, :labels => [nil] | Time::RFC2822_DAY_NAME)
    data = [
    {'row' => 'prototype', 'column' => '1', 'value' => '1.0' },
    {'row' => 'prototype-opt', 'column' => '2', 'value' => '1.0' },
    ]
    d = ReportResultData.new(row,column,nil,data)
    assert_equal( ['1', '2'], d.column_headers )
    assert_equal( ['prototype', 'prototype-opt'], d.row_headers )
  end
end
