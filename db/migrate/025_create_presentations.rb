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
class CreatePresentations < ActiveRecord::Migration
  class Presentation < ActiveRecord::Base
  end

  def self.up
    create_table :presentations do |t|
      t.column :key, :string, :limit => 20, :null => false
      t.column :name, :string, :limit => 120, :null => false
    end
    add_index :presentations, [:id], :unique => true
    add_index :presentations, [:key], :unique => true
    add_index :presentations, [:name], :unique => true

    Presentation.create!(:name => 'Pivot Table', :key => 'pivot')
    Presentation.create!(:name => 'Success Rate Table', :key => 'success')
    Presentation.create!(:name => 'SQL + Raw Data', :key => 'raw')
  end

  def self.down
    drop_table :presentations
  end
end
