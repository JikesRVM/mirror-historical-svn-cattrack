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
class CreateDataPresentations < ActiveRecord::Migration
  class DataPresentation < ActiveRecord::Base
  end

  def self.up
    create_table :data_presentations do |t|
      t.column :name, :string, :limit => 120, :null => false
    end
    add_index :data_presentations, [:name], :unique => true

    create_table :data_presentation_params, :id => false, :force => true do |t|
      t.column :owner_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :value, :string, :limit => 256, :null => false
    end
    add_index :data_presentation_params, [:owner_id, :key], :unique => true
    add_index :data_presentation_params, [:owner_id]
    add_index :data_presentation_params, [:owner_id, :key, :value]
    add_foreign_key :data_presentation_params, [:owner_id], :data_presentations, [:id], :on_delete => :cascade
  end

  def self.down
    drop_table :data_presentation_params
    drop_table :data_presentations
  end
end
