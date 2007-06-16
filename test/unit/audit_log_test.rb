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

class AuditLogTest < Test::Unit::TestCase
  def test_label
    assert_equal( AuditLog.find(1).name, AuditLog.find(1).label )
  end

  def test_basic_load
    audit_log = AuditLog.find(1)
    assert_equal( 1, audit_log.id )
    assert_equal( "user.created", audit_log.name )
    assert_equal( "2005-10-20T00:15:35Z", audit_log.created_at.xmlschema )
    assert_equal( '123.3.2.1', audit_log.ip_address )
    assert_equal( 'User 23 (Bob) created', audit_log.message )
    assert_equal( 1, audit_log.user_id )
    assert_equal( 1, audit_log.user.id )
  end

  def self.attributes_for_new
    {:name => 'test-run.created', :message => 'X' }
  end
  def self.non_null_attributes
    [:name]
  end
  def self.str_length_attributes
    [[:name, 120], [:ip_address, 24]]
  end
  def self.bad_attributes
    [[:name, '*']]
  end

  perform_basic_model_tests
end
