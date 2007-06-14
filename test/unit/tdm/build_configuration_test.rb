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

class Tdm::BuildConfigurationTest < Test::Unit::TestCase
  def test_label
    assert_equal( Tdm::BuildConfiguration.find(1).name, Tdm::BuildConfiguration.find(1).label )
  end

  def test_parent_node
    assert_parent_node(Tdm::BuildConfiguration.find(1),Tdm::TestRun,1)
  end

  def test_basic_load
    bc = Tdm::BuildConfiguration.find(1)
    assert_equal( "prototype", bc.name )
    assert_equal( "SUCCESS", bc.result )
    assert_equal( 10323, bc.time )
    assert_equal( "Prototype build log here ...", bc.output )
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
    {:test_run_id => 1, :name => 'foooish', :result => 'SUCCESS', :time => 142, :output => 'foooish!'}
  end
  def self.non_null_attributes
    [:name, :result, :time, :output]
  end
  def self.bad_attributes
    [[:time, -1],[:result, 'Foo'],[:name, '.']]
  end

  perform_basic_model_tests

  def test_new_with_output
    bc = Tdm::BuildConfiguration.new(self.class.attributes_for_new)
    bc.save!
    bc = Tdm::BuildConfiguration.find(bc.id)
    assert_equal( 'foooish!', bc.output )
  end
end
