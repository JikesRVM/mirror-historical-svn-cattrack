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
class CreateAuditLogs < ActiveRecord::Migration
  def self.up
    create_table :audit_logs do |t|
      t.column :name, :string, :limit => 120, :null => false
      t.column :created_at, :timestamp, :null => false
      t.column :user_id, :integer, :null => true
      t.column :username, :string, :limit => 40, :null => true
      t.column :ip_address, :string, :limit => 24, :null => true
      t.column :message, :text, :null => false
    end
    add_index :audit_logs, [:id], :unique => true
    add_index :audit_logs, [:name]
    add_index :audit_logs, [:created_at]
    add_index :audit_logs, [:user_id]
    add_index :audit_logs, [:name, :created_at]
    add_index :audit_logs, [:name, :created_at, :user_id]
    add_foreign_key :audit_logs, [:user_id], :users, [:id], :on_delete => :set_null
   end

  def self.down
    drop_table :audit_logs
  end
end
