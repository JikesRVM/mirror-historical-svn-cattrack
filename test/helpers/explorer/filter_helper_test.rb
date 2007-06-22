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

class Explorer::FilterHelperTest < Test::Unit::TestCase

  class MyClass
    include Explorer::FilterHelper
    attr_accessor :filter
  end

  def test_headers
    assert_equal("<a href=\"#\" id=\"time_dimension_toggle\" class=\"toggle_visibility open\" onclick=\"Element.toggle('time_dimension_table'); Element.toggleClassName('time_dimension_toggle','open'); return false;\">Time Dimension</a>", MyClass.new.section_header('time_dimension'))
    assert_equal("<a href=\"#\" id=\"time_dimension_toggle\" class=\"toggle_visibility open\" onclick=\"Element.toggle('time_dimension_table'); Element.toggleClassName('time_dimension_toggle','open'); return false;\">Time Dimension</a>", MyClass.new.dimension_header(Olap::TimeDimension))
  end

  def test_hide_dimension_javascript
    assert_equal("Element.toggle('time_dimension_table'); Element.toggleClassName('time_dimension_toggle','open')", MyClass.new.hide_dimension_javascript('time_dimension'))
  end

  def test_dimension_block_name
    assert_equal("time_dimension_table", MyClass.new.dimension_block_name(Olap::TimeDimension))
  end

  def test_dimension_footer
    o = MyClass.new
    o.filter = Olap::Query::Filter.new
    assert_equal("<script type=\"text/javascript\">Element.toggle('time_dimension_table'); Element.toggleClassName('time_dimension_toggle','open')</script>", o.dimension_footer(Olap::TimeDimension))
    o.filter.time_before = 'x'
    assert_equal("", o.dimension_footer(Olap::TimeDimension))
  end
end
