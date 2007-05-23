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
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  self.pre_loaded_fixtures = true
  self.display_invalid_content = true
  self.auto_validate = true

  fixtures ::OrderedTables

  def assert_params_same(expected,actual)
    assert_equal( expected.size, actual.size )
    expected.each do |k, v|
      assert_equal( actual[k], v, "Testing Key #{k}" )
    end
  end
end
