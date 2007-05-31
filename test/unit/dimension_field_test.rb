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

class DimensionFieldTest < Test::Unit::TestCase
  def test_label
    f = DimensionField.new(SearchField.new(TestCaseDimension, :name))
    assert_equal( TestCaseDimension, f.dimension )
    assert_equal( 'test_case_dimensions.name', f.id )
    assert_equal( 'Test case/Name', f.label )
  end
end
