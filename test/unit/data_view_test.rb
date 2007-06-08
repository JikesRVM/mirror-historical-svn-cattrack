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

class DataViewTest < Test::Unit::TestCase
  def test_basic_load
    data_view = DataView.find(1)
    assert_equal( 1, data_view.id )
    assert_equal( 1, data_view.filter_id )
    assert_equal( 1, data_view.filter.id )
    assert_equal( 1, data_view.summarizer_id )
    assert_equal( 1, data_view.summarizer.id )
    assert_equal( 1, data_view.data_presentation_id )
    assert_equal( 1, data_view.data_presentation.id )
  end

  def self.attributes_for_new
    {:filter_id => 1, :summarizer_id => 1, :data_presentation_id => 1}
  end
  def self.non_null_attributes
    [:filter_id, :summarizer_id, :data_presentation_id]
  end

  perform_basic_model_tests
end
