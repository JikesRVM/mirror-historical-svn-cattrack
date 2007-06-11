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

class HostTest < Test::Unit::TestCase
  def test_label
    assert_equal( "skunk", hosts(:host_skunk).label )
  end

  def test_parent_node
    assert_parent_node(hosts(:host_skunk),nil)
  end

  def test_basic_load
    host = hosts(:host_skunk)
    assert_equal( 1, host.id )
    assert_equal( "skunk", host.name )
    assert_equal( [1], host.test_run_ids )
  end

  def self.attributes_for_new
    { :name => 'foo', }
  end
  def self.non_null_attributes
    [:name]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 101]]
  end
  def self.bad_attributes
    [[:name, '*']]
  end

  perform_basic_model_tests
end
