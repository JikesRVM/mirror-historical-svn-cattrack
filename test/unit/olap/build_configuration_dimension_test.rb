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

class Olap::BuildConfigurationDimensionTest < Test::Unit::TestCase
  def test_basic_load
    object = Olap::BuildConfigurationDimension.find(1)
    assert_equal( 1, object.id )
    assert_equal( 'prototype', object.name )
    assert_equal( 'base', object.bootimage_compiler )
    assert_equal( 'base', object.runtime_compiler )
    assert_equal( 'org.mmtk.plan.generational.marksweep.GenMS', object.mmtk_plan )
    assert_equal( 'normal', object.assertion_level )
    assert_equal( 'minimal', object.bootimage_class_inclusion_policy )
  end

  def self.attributes_for_new
    {
    :name => 'foo',
    :bootimage_compiler => 'base',
    :runtime_compiler => 'base',
    :mmtk_plan => 'org.mmtk.plan.generational.marksweep.GenMS',
    :assertion_level => 'normal',
    :bootimage_class_inclusion_policy => 'minimal'}
  end
  def self.non_null_attributes
    [:name, :bootimage_compiler, :runtime_compiler, :mmtk_plan, :assertion_level, :bootimage_class_inclusion_policy]
  end
  def self.str_length_attributes
    [[:name, 76], [:bootimage_compiler, 11], [:runtime_compiler, 11], [:mmtk_plan, 51], [:assertion_level, 11], [:bootimage_class_inclusion_policy, 11]]
  end
  def self.bad_attributes
    [[:bootimage_compiler, 'X'], [:runtime_compiler, 'X'], [:assertion_level, 'X'], [:bootimage_class_inclusion_policy, 'X']]
  end

  perform_basic_model_tests(:skip => [:destroy])
end
