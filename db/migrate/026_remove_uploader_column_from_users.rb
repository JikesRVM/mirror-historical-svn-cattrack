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
class RemoveUploaderColumnFromUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def self.up
    remove_column(:users, :uploader)
    User.find_by_username('upload_tool').destroy
  end

  def self.down
  end
end
