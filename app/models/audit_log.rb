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
class AuditLog < ActiveRecord::Base
  validates_format_of :name, :with => /^[\-a-zA-Z_0-9\.]+$/
  validates_length_of :name, :in => 1..120
  validates_length_of :username, :in => 1..40, :allow_nil => true
  validates_length_of :ip_address, :in => 0..24, :allow_nil => true
  validates_reference_exists :user_id, User
  belongs_to :user

  cattr_accessor :current_user, :current_ip_address

  def self.log(event, message = '')
    message = "id=#{message.id} (#{message.label})" if message.is_a? ActiveRecord::Base
    AuditLog.create!(:name => event, :message => message, :user_id => current_user ? current_user.id : nil, :username => current_user ? current_user.username : nil, :ip_address => current_ip_address)
  end
end
