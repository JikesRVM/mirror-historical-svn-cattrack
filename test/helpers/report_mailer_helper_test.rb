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

class ReportMailerHelperTest < Test::Unit::TestCase

  class MyClass
    include ReportMailerHelper
  end

  def test_test_run_label
    test_runs = [Tdm::TestRun.find(1)]
    assert_equal(['20/10'], do_label_test(test_runs))
    test_runs << Tdm::TestRun.find(2)
    assert_equal(["20/10", "07/11"], do_label_test(test_runs))
    test_run_1 = clone_test_run(Tdm::TestRun.find(1), -120)
    test_runs << test_run_1
    assert_equal(["20/10 00:00", "07/11", "20/10 00:02"], do_label_test(test_runs))
  end

  def do_label_test(test_runs)
    test_runs.collect do |tr|
      MyClass.new.test_run_label(tr, test_runs)
    end
  end
end
