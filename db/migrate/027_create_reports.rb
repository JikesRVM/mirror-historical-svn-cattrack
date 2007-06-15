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
class CreateReports < ActiveRecord::Migration
  def self.up
    create_table :reports do |t|
      t.column :name, :string, :limit => 120, :null => false
      t.column :description, :string, :limit => 256, :null => false
      t.column :presentation_id, :integer, :null => false
      t.column :query_id, :integer, :null => false
    end
    add_index :reports, [:id], :unique => true
    add_index :reports, [:name], :unique => true
    add_foreign_key :reports, [:presentation_id], :presentations, [:id], :on_delete => :cascade
    add_foreign_key :reports, [:query_id], :queries, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :reports
  end
end
