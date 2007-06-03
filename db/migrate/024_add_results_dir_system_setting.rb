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
class AddResultsDirSystemSetting < ActiveRecord::Migration
  class SystemSetting < ActiveRecord::Base
  end

  def self.up
    SystemSetting.create!(:name => 'results.dir', :value => "#{File.expand_path(RAILS_ROOT)}/results")
    SystemSetting.find_by_name('tmp.dir').destroy
  end

  def self.down
  end
end
