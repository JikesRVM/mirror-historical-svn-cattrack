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

class Reports::TestRunByRevisionReportHelperTest < Test::Unit::TestCase

  class MyClass
    include ERB::Util
    include ApplicationHelper
  end

  def test_revision_link
    assert_equal("<a href=\"http://svn.sourceforge.net/viewvc/jikesrvm?view=rev&amp;revision=22\">22</a>", MyClass.new.revision_link(22))
  end
end
