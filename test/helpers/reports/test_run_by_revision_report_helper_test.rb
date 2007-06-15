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
require File.dirname(__FILE__) + '/../../test_helper'

class Reports::TestRunByRevisionReportHelperTest < Test::Unit::TestCase

  class MyClass
    include Reports::TestRunByRevisionReportHelper
  end

  def test_cell_rendering
    assert_equal('<td style="background-color: rgb(0,255,0);">100%</td>', MyClass.new.cell(100))
    assert_equal('<td style="background-color: rgb(32,191,0);">85%</td>', MyClass.new.cell(85))
    assert_equal('<td style="background-color: rgb(64,127,0);">55%</td>', MyClass.new.cell(55))
    assert_equal('<td style="background-color: rgb(0,127,0);">35%</td>', MyClass.new.cell(35))
    assert_equal('<td style="background-color: rgb(255,0,0);">0%</td>', MyClass.new.cell(0))
  end

  def test_tests_header
    assert_equal("<a href=\"#\" id=\"new_failures_toggle\" class=\"toggle_visibility\" onclick=\"Element.toggle('new_failures'); Element.toggleClassName('new_failures_toggle','open'); return false;\">3 New Failures</a>", MyClass.new.tests_header('new_failures', '3 New Failures'))
  end

  def test_column_header
    assert_equal("<th class=\"column\">core-1</th>", MyClass.new.column_header('1',Tdm::TestRun.find(:all, :conditions => 'id = 1')))
  end
end