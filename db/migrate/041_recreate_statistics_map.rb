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
class RecreateStatisticsMap < ActiveRecord::Migration
  class StatisticsMap < ActiveRecord::Base
    set_table_name 'statistics_map'
  end

  def self.up
    ActiveRecord::Base.transaction do
      drop_table :statistics_name_map

      create_table :statistics_map do |t|
        t.column :test_run_name, :string, :limit => 75, :null => true
        t.column :build_configuration_name, :string, :limit => 75, :null => true
        t.column :test_configuration_name, :string, :limit => 75, :null => true
        t.column :group_name, :string, :limit => 75, :null => false
        t.column :test_case_name, :string, :limit => 75, :null => false
        t.column :statistic_key, :string, :limit => 50, :null => false
        t.column :name, :string, :limit => 50, :null => false
        t.column :statistic_function, :string, :limit => 75, :null => false
        t.column :less_is_more, :boolean, :null => false
        t.column :label, :string, :limit => 75, :null => false
      end
      add_index :statistics_map, [:id], :unique => true
      add_index :statistics_map, [:test_run_name, :build_configuration_name, :test_configuration_name, :group_name, :test_case_name, :statistic_key], :unique => true
      add_index :statistics_map, [:test_run_name]
      add_index :statistics_map, [:build_configuration_name]
      add_index :statistics_map, [:test_configuration_name]
      add_index :statistics_map, [:group_name]
      add_index :statistics_map, [:test_case_name]
      add_index :statistics_map, [:statistic_key]

      [
      [nil, 'production', 'Performance', 'SPECjbb2005', 'SPECjbb2005', 'score', false, 'SPECjbb2005','average'],
      [nil, 'production', 'default', 'SPECjbb2000', 'SPECjbb2000', 'score', false, 'SPECjbb2000','average'],
      [nil, 'production', 'Performance', 'SPECjvm98', 'SPECjvm98', 'aggregate.best.score', false, 'SPECjvm98','average'],
      [nil, 'production', 'default', 'dacapo', 'antlr', 'time', true, 'dacapo: antlr','average'],
      [nil, 'production', 'default', 'dacapo', 'bloat', 'time', true, 'dacapo: bloat','average'],
      [nil, 'production', 'default', 'dacapo', 'chart', 'time', true, 'dacapo: chart','average'],
      [nil, 'production', 'default', 'dacapo', 'eclipse', 'time', true, 'dacapo: eclipse','average'],
      [nil, 'production', 'default', 'dacapo', 'fop', 'time', true, 'dacapo: fop','average'],
      [nil, 'production', 'default', 'dacapo', 'hsqldb', 'time', true, 'dacapo: hsqldb','average'],
      [nil, 'production', 'default', 'dacapo', 'jython', 'time', true, 'dacapo: jython','average'],
      [nil, 'production', 'default', 'dacapo', 'luindex', 'time', true, 'dacapo: luindex','average'],
      [nil, 'production', 'default', 'dacapo', 'lusearch', 'time', true, 'dacapo: lusearch','average'],
      [nil, 'production', 'default', 'dacapo', 'pmd', 'time', true, 'dacapo: pmd','average'],
      [nil, 'production', 'default', 'dacapo', 'sunflow', 'time', true, 'dacapo: sunflow','average'],
      [nil, 'production', 'default', 'dacapo', 'xalan', 'time', true, 'dacapo: xalan','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Sieve.run2', false, 'CaffeineMark: Sieve','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Loop.run2', false, 'CaffeineMark: Loop','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Logic.run2', false, 'CaffeineMark: Logic','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'String.run2', false, 'CaffeineMark: String','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Float.run2', false, 'CaffeineMark: Float','average'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Method.run2', false, 'CaffeineMark: Method','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'NumericSort.index', false, 'jBYTEmark: Numeric Sort','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'StringSort.index', false, 'jBYTEmark: String Sort','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'BitfieldOperations.index', false, 'jBYTEmark: Bitfield Operations','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'FPEmulation.index', false, 'jBYTEmark: FP Emulation','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Fourier.index', false, 'jBYTEmark: Fourier','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Assignment.index', false, 'jBYTEmark: Assignment','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'IDEAEncryption.index', false, 'jBYTEmark: IDEA Encryption','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'HuffmanCompression.index', false, 'jBYTEmark: Huffman Compression','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'NeuralNet.index', false, 'jBYTEmark: Neural Net','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'LUDecomposition.index', false, 'jBYTEmark: LU Decomposition','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Integer.index', false, 'jBYTEmark: Integer','average'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'FP.index', false, 'jBYTEmark: FP','average'],
      [nil, 'production', 'default', 'basic', 'ImageSizes', 'total.size', true, 'Boot Image Size: Total','average'],
      ].each do |r|
        StatisticsMap.create!(:test_run_name => r[0],
        :build_configuration_name => r[1],
        :test_configuration_name => r[2],
        :group_name => r[3],
        :test_case_name => r[4],
        :statistic_key => r[5],
        :name => r[5],
        :less_is_more => r[6],
        :label => r[7],
        :statistic_function => r[8])
      end
    end
  end

  def self.down
  end
end
