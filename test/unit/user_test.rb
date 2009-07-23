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

class UserTest < Test::Unit::TestCase
  def test_basic_load
    user = users(:user_peter)
    assert_equal(1, user.id)
    assert_equal('peter', user.username)
    assert_equal('MyMostMagicSaltiness', user.salt)
    assert_equal(true, user.admin?)
    assert_equal(true, user.active?)
  end

  self.perform_all_models_valid_test
  self.perform_fixtures_correct_size_test

  def test_name_too_long
    user = User.new(:username => ('f'*41), :salt => 'salt', :password => 'password', :admin => true)
    assert_equal(false, user.valid?)
    assert_not_nil(user.errors[:username])
  end

  def test_authenticate_correct_password
    user = User.authenticate(users(:user_peter).username, 'retep')
    assert user
  end

  def test_authenticate_incorrect_password
    user = User.authenticate(users(:user_peter).username, 'bad_password')
    assert_nil user
  end

  def test_authenticate_inactive_user
    user = User.authenticate(users(:user_morpheus).username, 'redpill')
    assert_nil user
  end

  def test_authenticate_missing
    user = User.authenticate('no-exist', 'letmein')
    assert_nil user
  end

  def test_set_password
    password = 'secret'
    user = User.new
    user.password = password
    assert(user.password_matches?(password))
  end

  def test_get_label
    assert_equal('peter', users(:user_peter).label)
  end

  def test_get_password
    assert_equal('', users(:user_peter).password)
  end

  def test_password_matches?
    assert(users(:user_peter).password_matches?('retep'))
  end
end
