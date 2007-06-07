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

class BuildConfigurationTest < Test::Unit::TestCase
  def test_label
    assert_equal( 'prototype', build_configurations(:bc1).label )
  end

  def test_parent_node
    assert_parent_node(build_configurations(:bc1),TestRun,1)
  end

  def test_basic_load
    bc = build_configurations(:bc1)
    assert_equal( "prototype", bc.name )
    prototype_params =
    {
    'config.name' => 'prototype',
    'config.runtime.compiler' => 'base',
    'config.bootimage.compiler' => 'base',
    'config.mmtk.plan' => 'org.mmtk.plan.generational.marksweep.GenMS',
    'config.include.aos' => '0',
    'config.include.opt-harness' => '0',
    'config.include.gcspy' => '0',
    'config.include.gcspy-stub' => '0',
    'config.include.gcspy-client' => '0',
    'config.include.all-classes' => '0',
    'config.assertions' => 'normal',
    'config.default-heapsize.initial' => '20',
    'config.default-heapsize.maximum' => '100',
    'config.bootimage.compiler.args' => '',
    'config.stress-gc' => ''
    }
    assert_params_same(prototype_params,bc.params)
  end

  def self.attributes_for_new
    {:test_run_id => 1, :name => 'foooish!'}
  end
  def self.non_null_attributes
    [:name]
  end

  perform_basic_model_tests

end
