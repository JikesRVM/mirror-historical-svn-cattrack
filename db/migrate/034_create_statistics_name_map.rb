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
class CreateStatisticsNameMap < ActiveRecord::Migration
  class StatisticsNameMap < ActiveRecord::Base
    set_table_name 'statistics_name_map'
  end

  def self.up
    create_table :statistics_name_map do |t|
      t.column :group_name, :string, :limit => 75, :null => false
      t.column :test_case_name, :string, :limit => 75, :null => false
      t.column :key, :string, :limit => 50, :null => false
      t.column :mode, :string, :limit => 50, :null => false
      t.column :less_is_more, :boolean, :null => false
      t.column :label, :string, :limit => 75, :null => false
    end
    add_index :statistics_name_map, [:id], :unique => true
    add_index :statistics_name_map, [:group_name, :test_case_name, :key, :mode], :unique => true
    add_index :statistics_name_map, [:group_name]
    add_index :statistics_name_map, [:test_case_name]
    add_index :statistics_name_map, [:key]
    add_index :statistics_name_map, [:mode]

    [
    ['SPECjbb2005','SPECjbb2005','score',false,'SPECjbb2005','performance'],
    ['SPECjbb2000','SPECjbb2000','score',false,'SPECjbb2000',''],
    ['SPECjvm98','SPECjvm98','aggregate.best.score',false,'SPECjvm98','performance'],
    ['dacapo','antlr','time',true,'dacapo: antlr',''],
    ['dacapo','bloat','time',true,'dacapo: bloat',''],
    ['dacapo','chart','time',true,'dacapo: chart',''],
    ['dacapo','eclipse','time',true,'dacapo: eclipse',''],
    ['dacapo','fop','time',true,'dacapo: fop',''],
    ['dacapo','hsqldb','time',true,'dacapo: hsqldb',''],
    ['dacapo','jython','time',true,'dacapo: jython',''],
    ['dacapo','luindex','time',true,'dacapo: luindex',''],
    ['dacapo','lusearch','time',true,'dacapo: lusearch',''],
    ['dacapo','pmd','time',true,'dacapo: pmd',''],
    ['dacapo','sunflow','time',true,'dacapo: sunflow',''],
    ['dacapo','xalan','time',true,'dacapo: xalan',''],
    ['CaffeineMark','CaffeineMark','Sieve.run2',false,'CaffeineMark: Sieve',''],
    ['CaffeineMark','CaffeineMark','Loop.run2',false,'CaffeineMark: Loop',''],
    ['CaffeineMark','CaffeineMark','Logic.run2',false,'CaffeineMark: Logic',''],
    ['CaffeineMark','CaffeineMark','String.run2',false,'CaffeineMark: String',''],
    ['CaffeineMark','CaffeineMark','Float.run2',false,'CaffeineMark: Float',''],
    ['CaffeineMark','CaffeineMark','Method.run2',false,'CaffeineMark: Method',''],
    ['jBYTEmark','jBYTEmark','NumericSort.index',false,'jBYTEmark: Numeric Sort',''],
    ['jBYTEmark','jBYTEmark','StringSort.index',false,'jBYTEmark: String Sort',''],
    ['jBYTEmark','jBYTEmark','BitfieldOperations.index',false,'jBYTEmark: Bitfield Operations',''],
    ['jBYTEmark','jBYTEmark','FPEmulation.index',false,'jBYTEmark: FP Emulation',''],
    ['jBYTEmark','jBYTEmark','Fourier.index',false,'jBYTEmark: Fourier',''],
    ['jBYTEmark','jBYTEmark','Assignment.index',false,'jBYTEmark: Assignment',''],
    ['jBYTEmark','jBYTEmark','IDEAEncryption.index',false,'jBYTEmark: IDEA Encryption',''],
    ['jBYTEmark','jBYTEmark','HuffmanCompression.index',false,'jBYTEmark: Huffman Compression',''],
    ['jBYTEmark','jBYTEmark','NeuralNet.index',false,'jBYTEmark: Neural Net',''],
    ['jBYTEmark','jBYTEmark','LUDecomposition.index',false,'jBYTEmark: LU Decomposition',''],
    ['jBYTEmark','jBYTEmark','Integer.index',false,'jBYTEmark: Integer',''],
    ['jBYTEmark','jBYTEmark','FP.index',false,'jBYTEmark: FP',''],
    ].each do |r|
      StatisticsNameMap.create!(:group_name => r[0], :test_case_name => r[1], :key => r[2], :less_is_more => r[3], :label => r[4], :mode => r[5])
    end
  end

  def self.down
    drop_table :statistics_name_map
  end
end
