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

  def test_tests_header
    assert_equal("<a href=\"#\" id=\"new_failures_toggle\" class=\"toggle_visibility open\" onclick=\"Element.toggle('new_failures'); Element.toggleClassName('new_failures_toggle','open'); return false;\">3 New Failures</a>", MyClass.new.tests_header('new_failures', '3 New Failures'))
  end

  def test_hide_tests_javascript
    assert_equal("Element.toggle('new_failures'); Element.toggleClassName('new_failures_toggle','open')", MyClass.new.hide_tests_javascript('new_failures'))
  end

  def test_perf_stat
    row = {'std_deviation' => '1', 'best_score' => '2'}
    assert_equal("", MyClass.new.perf_stat(1, row.merge({"test_run_1" => nil})))
    assert_equal("<span style=\"color: green; font-weight: bold;\">2</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '2'})))
    assert_equal("<span style=\"color: green;\">1.9</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '1.9'})))
    assert_equal("<span style=\"\">1.5</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '1.5'})))
    assert_equal("<span style=\"color: red;\">1.1</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '1.1'})))
    assert_equal("<span style=\"color: red; font-weight: bold;\">0.2</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '0.2'})))
  end

end
