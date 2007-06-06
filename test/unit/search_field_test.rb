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
  def test_basic_properties
    f = SearchField.new(TestConfigurationDimension,:name, :foo => 'bar')
    assert_equal( TestConfigurationDimension, f.dimension )
    assert_equal( 'TestConfiguration', f.dimension_name )
    assert_equal( :name, f.name )
    assert_equal( :test_configuration_name, f.key )
    assert_equal( 4, f.options.size )
    assert_equal( 4, f.options[:size] )
    assert_equal( true, f.options[:any] )
    assert_equal( true, f.options[:multiple] )
    assert_equal( 'bar', f.options[:foo] )
  end

  def test_labels
    f = SearchField.new(TimeDimension, :month, :labels => [nil] | Time::RFC2822_MONTH_NAME)
    assert_equal( 'Jan', f.label_for(1) )
  end
end
