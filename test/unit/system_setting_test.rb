#
#  This file is part of the Jikes RVM project (http://jikesrvm.org).
#
#  This file is licensed to You under the Eclipse Public License (EPL);
#  You may not use this file except in compliance with the License. You
#  may obtain a copy of the License at
#
#      http://www.opensource.org/licenses/cpl1.0.php
#
#  See the COPYRIGHT.txt file distributed with this work for information
#  regarding copyright ownership.
#
require File.dirname(__FILE__) + '/../test_helper'

class SystemSettingTest < Test::Unit::TestCase
   def test_basic_load
      system_setting = system_settings(:s_environment)
      assert_equal( 1, system_setting.id )
      assert_equal( 'environment', system_setting.name )
      assert_equal( 'test', system_setting.value )
      assert_equal( true, system_setting.valid? )
   end

   def test_array_read
      assert_equal( 'test', SystemSetting['environment'] )
   end

   def test_array_write_for_existing
      assert_equal( 'test', SystemSetting['environment'] )
      SystemSetting['environment'] = '42'
      assert_equal( '42', SystemSetting['environment'] )
   end

   def test_array_write_for_new
      assert_nil( SystemSetting['flux capacitor'] )
      SystemSetting['flux capacitor'] = '42'
      assert_equal( '42', SystemSetting['flux capacitor'] )
   end
end
