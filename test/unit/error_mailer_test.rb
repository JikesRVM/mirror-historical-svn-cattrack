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

class ErrorMailerTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  def test_error
    response = nil
    begin
      raise 'yer baby - this is an error'
    rescue => e
      response = ErrorMailer.create_error(e)
    end

    assert_equal('CatTrack Error', response.subject)
    assert_equal(["peter@realityforge.org"], response.to)
    assert_equal(["rvm-regression@cs.anu.edu.au"], response.from)
    assert_equal("1.0", response.mime_version)
    assert_equal("text/html", response.content_type)
    assert_match(/yer baby - this is an error/, response.body)
  end
end
