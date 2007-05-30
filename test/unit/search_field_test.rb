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

class SearchFieldTest < Test::Unit::TestCase
  def test_label
    f = SearchField.new(TestConfigurationDimension,:name)
    assert_equal( :name, f.name )
    assert_equal( :test_configuration_name, f.key )
  end
end
