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
class User < ActiveRecord::Base
  auto_validations :only => [:username, :admin]

  def self.authenticate(name, password)
    user = find_by_username(name)
    return nil unless user
    find(:first,  :conditions => ['username = ? AND password = ?', name, User.encode_password(user.salt, password)])
  end

  def password_matches?(password)
    User.encode_password(self.salt, password) == read_attribute('password')
  end

  def label
    username
  end

  def password
    ''
  end

  def password=(password)
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{username}--")
    write_attribute('password', User.encode_password(self.salt, password))
  end

  private
  def self.encode_password(salt, password)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end
end
