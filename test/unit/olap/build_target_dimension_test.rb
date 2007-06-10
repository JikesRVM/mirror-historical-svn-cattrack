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

class Olap::BuildTargetDimensionTest < Test::Unit::TestCase
  def test_basic_load
    object = Olap::BuildTargetDimension.find(1)
    assert_equal( 1, object.id )
    assert_equal( 'ia32_linux', object.name )
    assert_equal( 'ia32', object.arch )
    assert_equal( 32, object.address_size )
    assert_equal( 'Linux', object.operating_system )
  end

  def self.attributes_for_new
    {:name => 'foo', :arch => 'ia32', :address_size => 64, :operating_system => 'Linux'}
  end
  def self.non_null_attributes
    [:name, :arch, :address_size, :operating_system]
  end

  def self.str_length_attributes
    [[:name, 76], [:arch, 11], [:operating_system, 51]]
  end

  def self.bad_attributes
    [[:address_size, 50]]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
