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
class CreateSessions < ActiveRecord::Migration
   def self.up
      create_table :sessions, :force => true do |t|
         t.column :sessid, :string, :limit => 32, :null => false
         t.column :data, :text
         t.column :created_on, :timestamp, :null => false
         t.column :updated_on, :timestamp, :null => false
      end
      add_index :sessions, [:sessid], :unique => true
   end

   def self.down
      drop_table :sessions
   end
end
