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
class CreateSystemSettings < ActiveRecord::Migration
  class SystemSetting < ActiveRecord::Base
  end

  def self.up
    create_table :system_settings do |t|
      t.column :name, :string, :null => false, :limit => 255
      t.column :value, :text, :null => false
    end

    add_index :system_settings, [:id], :unique => true
    add_index :system_settings, [:name], :unique => true

    SystemSetting.create!(:name => 'environment', :value => ENV['SELECTED_ENV'] || ENV['RAILS_ENV'] || RAILS_ENV)
    SystemSetting.create!(:name => 'minor.version', :value => '0')
    SystemSetting.create!(:name => 'session.timeout', :value => '20')
    SystemSetting.create!(:name => 'results.dir', :value => "#{File.expand_path(RAILS_ROOT)}/results")
    SystemSetting.create!(:name => 'scm.url', :value => "http://svn.sourceforge.net/viewvc/jikesrvm?view=rev&revision=@@revision@@")
  end

  def self.down
    drop_table :system_settings
  end
end
