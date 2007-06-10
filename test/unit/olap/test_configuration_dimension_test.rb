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

class Olap::TestConfigurationDimensionTest < Test::Unit::TestCase
  def test_basic_load
    object = Olap::TestConfigurationDimension.find(1)
    assert_equal( 1, object.id )
    assert_equal( 'prototype', object.name )
    assert_equal( '', object.mode )
  end

  def self.attributes_for_new
    {:name => 'foo', :mode => 'performance'}
  end
  def self.non_null_attributes
    [:name, :mode]
  end

  def self.str_length_attributes
    [[:name, 76], [:mode, 76]]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
