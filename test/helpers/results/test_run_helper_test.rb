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

class Results::TestRunHelperTest < Test::Unit::TestCase

  class MyClass
    include Results::TestRunHelper
    include ERB::Util
    include ActionView::Helpers::TextHelper
  end

  def test_tests_header
    assert_equal("<a href=\"#\" id=\"new_failures_toggle\" class=\"toggle_visibility open\" onclick=\"Element.toggle('new_failures'); Element.toggleClassName('new_failures_toggle','open'); return false;\">3 New Failures</a>", MyClass.new.tests_header('new_failures', '3 New Failures'))
  end

  def test_hide_tests_javascript
    assert_equal("Element.toggle('new_failures'); Element.toggleClassName('new_failures_toggle','open')", MyClass.new.hide_tests_javascript('new_failures'))
  end

  def test_perf_stat
    assert_equal("", MyClass.new.perf_stat(1, {}))

    values = [0.0, 0.8, 1.6, 2.4, 3].collect {|v| (4 - v).to_s }
    row = {'std_deviation' => '1', 'best_score' => '4', "less_is_more" => '0'}
    assert_equal("", MyClass.new.perf_stat(1, row.merge({"test_run_1" => nil})))
    assert_equal("<span style=\"color: green; font-weight: bold;\" title=\"4\">4</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '4'})))
    assert_equal("<span style=\"color: green;\" title=\"#{values[1]}\">#{values[1]}</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[1]})))
    assert_equal("<span style=\"\" title=\"#{values[2]}\">#{values[2]} (-40%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[2]})))
    assert_equal("<span style=\"color: red;\" title=\"#{values[3]}\">#{values[3]} (-60%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[3]})))
    assert_equal("<span style=\"color: red; font-weight: bold;\" title=\"#{values[4]}\">#{values[4]} (-75%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[4]})))

    values = [0.0, 0.8, 1.6, 2.4, 3].collect {|v| (4 + v).to_s }
    row = {'std_deviation' => '1', 'best_score' => '4', "less_is_more" => '1'}
    assert_equal("", MyClass.new.perf_stat(1, row.merge({"test_run_1" => nil})))
    assert_equal("<span style=\"color: green; font-weight: bold;\" title=\"4\">4</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => '4'})))
    assert_equal("<span style=\"color: green;\" title=\"#{values[1]}\">#{values[1]}</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[1]})))
    assert_equal("<span style=\"\" title=\"#{values[2]}\">#{values[2]} (+39%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[2]})))
    assert_equal("<span style=\"color: red;\" title=\"#{values[3]}\">#{values[3]} (+60%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[3]})))
    assert_equal("<span style=\"color: red; font-weight: bold;\" title=\"#{values[4]}\">#{values[4]} (+75%)</span>", MyClass.new.perf_stat(1, row.merge({"test_run_1" => values[4]})))

    assert_equal("<span style=\"color: green; font-weight: bold;\" title=\"10000000000\">10000...</span>", MyClass.new.perf_stat(1, {'std_deviation' => '1', 'best_score' => '10000000000', "less_is_more" => '1', "test_run_1" => '10000000000'}))
  end
end
