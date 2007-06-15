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

class Olap::Query::ReportTest < Test::Unit::TestCase
  def test_label
    assert_equal( Olap::Query::Report.find(1).name, Olap::Query::Report.find(1).label )
  end

  def test_basic_load
    report = Olap::Query::Report.find(1)
    assert_equal( 1, report.id )
    assert_equal( 'Success Rate by Build Configuration by Day of Week Report', report.name )
    assert_equal( '', report.description )
    assert_equal( 1, report.query_id )
    assert_equal( 1, report.query.id )
    assert_equal( 2, report.presentation_id )
    assert_equal( 2, report.presentation.id )
  end

  def self.attributes_for_new
    {:name => 'foo', :description => '', :query_id => 1, :presentation_id => 1}
  end
  def self.non_null_attributes
    [:name, :description, :presentation_id, :query_id]
  end
  def self.unique_attributes
    [[:name]]
  end
  def self.str_length_attributes
    [[:name, 120], [:description, 256]]
  end
  def self.bad_attributes
    [[:presentation_id, -2]]
  end

  perform_basic_model_tests
end
