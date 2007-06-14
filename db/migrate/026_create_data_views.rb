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
class CreateDataViews < ActiveRecord::Migration
  def self.up
    create_table :data_views do |t|
      t.column :filter_id, :integer, :null => false
      t.column :summarizer_id, :integer, :null => false
      t.column :presentation_id, :integer, :null => false
    end
    add_index :data_views, [:id], :unique => true
    add_foreign_key :data_views, [:filter_id], :filters, [:id], :on_delete => :cascade
    add_foreign_key :data_views, [:summarizer_id], :summarizers, [:id], :on_delete => :cascade
    add_foreign_key :data_views, [:presentation_id], :presentations, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :data_views
  end
end
