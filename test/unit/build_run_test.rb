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

class BuildRunTest < Test::Unit::TestCase
  def test_label
    assert_equal( 'prototype', build_runs(:b_1).label )
  end

  def test_parent_node
    assert_parent_node(build_runs(:b_1),TestRun,1)
  end

  def test_basic_load
    build = build_runs(:b_1)
    assert_equal( 1, build.id )
    assert_equal( "SUCCESS", build.result )
    assert_equal( 10323, build.time )
    assert_equal( "Prototype build log here ...", build.output )
    assert_equal( 1, build.build_configuration_id )
    assert_equal( 1, build.build_configuration.id )
    assert_equal( 1, build.test_run_id )
    assert_equal( 1, build.test_run.id )
  end

  def test_new_with_output
    br = BuildRun.new(self.class.attributes_for_new)
    br.save!
    br2 = BuildRun.find(br.id)
    assert_equal( 'foooish!', br2.output )
  end

  def test_remove_orphaned_build_configurations
    build_configuration = BuildConfiguration.create!(:name => 'BC')
    assert_equal(true,BuildConfiguration.exists?(build_configuration.id))
    build_run = BuildRun.new(self.class.attributes_for_new)
    build_run.build_configuration = build_configuration
    build_run.save!

    build_run.reload

    build_run.destroy
    assert_equal(false,BuildConfiguration.exists?(build_configuration.id))
  end

  def test_remove_orphaned_build_configurations_does_not_remove_non_orphaned
    build_configuration = BuildConfiguration.create!(:name => 'BC')
    assert_equal(true,BuildConfiguration.exists?(build_configuration.id))
    build_run = BuildRun.new(self.class.attributes_for_new)
    build_run.build_configuration = build_configuration
    build_run.save!

    build_run = BuildRun.new(self.class.attributes_for_new)
    build_run.build_configuration = build_configuration
    build_run.save!

    build_run.reload

    build_run.destroy
    assert_equal(true,BuildConfiguration.exists?(build_configuration.id))
  end

  def self.attributes_for_new
    {:test_run_id => 1, :build_configuration_id => 3, :result => 'SUCCESS', :time => 142, :output => 'foooish!'}
  end
  def self.non_null_attributes
    [:test_run_id, :build_configuration_id, :result, :time, :output]
  end
  def self.bad_attributes
    [[:time, -1],[:result, 'Foo']]
  end

  perform_basic_model_tests
end
