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
require File.dirname(__FILE__) + '/../../../test_helper'

class Olap::Query::SearchFieldTest < Test::Unit::TestCase
  def test_basic_properties
    f = Olap::Query::SearchField.new(Olap::TestConfigurationDimension,:name, :foo => 'bar')
    assert_equal( Olap::TestConfigurationDimension, f.dimension )
    assert_equal( 'TestConfiguration', f.dimension_name )
    assert_equal( :name, f.name )
    assert_equal( :test_configuration_name, f.key )
    assert_equal( 1, f.options.size )
    assert_equal( 'bar', f.options[:foo] )
    assert_equal( 'test_configuration_name', f.key_name )
    assert_equal( 'Test configuration Name', f.label )
  end

  def test_labels
    f = Olap::Query::SearchField.new(Olap::TimeDimension, :month, :labels => [nil] | Time::RFC2822_MONTH_NAME)
    assert_equal( 'Jan', f.label_for(1) )
  end
end
