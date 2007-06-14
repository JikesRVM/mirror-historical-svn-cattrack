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

class Tdm::BuildTargetTest < Test::Unit::TestCase

  def test_label
    assert_equal( "ia32_linux", Tdm::BuildTarget.find(1).label )
  end

  def test_parent_node
    assert_parent_node(Tdm::BuildTarget.find(1),Tdm::TestRun,1)
  end

  def test_basic_load
    bt = Tdm::BuildTarget.find(1)
    assert_equal( "ia32_linux", bt.name )
    target_params = { 'target.name' => 'ia32-linux',
                          'target.arch' => 'ia32',
                          'target.address.size' => '32',
                          'target.os' => 'Linux',
                          'target.bootimage.code.address' => '0x4B000000',
                          'target.bootimage.data.address' => '0x47000000',
                          'target.bootimage.rmap.address' => '0x4E000000',
                          'target.max-mappable.address' => '0xb0000000'
                        }
    assert_params_same(target_params,bt.params)
  end

  def self.attributes_for_new
    test_run = Tdm::TestRun.create!(:name => 'foo', :host_id => 1, :revision => 123, :occurred_at => Time.now)
    {:name => 'foo', :test_run_id => test_run.id}
  end
  def self.non_null_attributes
    [:name,:test_run_id]
  end
  def self.unique_attributes
    [[:test_run_id]]
  end
  def self.str_length_attributes
    [[:name, 76]]
  end
  def self.bad_attributes
    [[:name, '.']]
  end

  perform_basic_model_tests
end
