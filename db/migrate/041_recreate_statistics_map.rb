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
      [nil, 'production', 'Performance', 'SPECjbb2005', 'SPECjbb2005', 'score', false, 'SPECjbb2005'],
      [nil, 'production', 'default', 'SPECjbb2000', 'SPECjbb2000', 'score', false, 'SPECjbb2000'],
      [nil, 'production', 'Performance', 'SPECjvm98', 'SPECjvm98', 'aggregate.best.score', false, 'SPECjvm98'],
      [nil, 'production', 'default', 'dacapo', 'antlr', 'time', true, 'dacapo: antlr'],
      [nil, 'production', 'default', 'dacapo', 'bloat', 'time', true, 'dacapo: bloat'],
      [nil, 'production', 'default', 'dacapo', 'chart', 'time', true, 'dacapo: chart'],
      [nil, 'production', 'default', 'dacapo', 'eclipse', 'time', true, 'dacapo: eclipse'],
      [nil, 'production', 'default', 'dacapo', 'fop', 'time', true, 'dacapo: fop'],
      [nil, 'production', 'default', 'dacapo', 'hsqldb', 'time', true, 'dacapo: hsqldb'],
      [nil, 'production', 'default', 'dacapo', 'jython', 'time', true, 'dacapo: jython'],
      [nil, 'production', 'default', 'dacapo', 'luindex', 'time', true, 'dacapo: luindex'],
      [nil, 'production', 'default', 'dacapo', 'lusearch', 'time', true, 'dacapo: lusearch'],
      [nil, 'production', 'default', 'dacapo', 'pmd', 'time', true, 'dacapo: pmd'],
      [nil, 'production', 'default', 'dacapo', 'sunflow', 'time', true, 'dacapo: sunflow'],
      [nil, 'production', 'default', 'dacapo', 'xalan', 'time', true, 'dacapo: xalan'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Sieve.run2', false, 'CaffeineMark: Sieve'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Loop.run2', false, 'CaffeineMark: Loop'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Logic.run2', false, 'CaffeineMark: Logic'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'String.run2', false, 'CaffeineMark: String'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Float.run2', false, 'CaffeineMark: Float'],
      [nil, 'production', 'default', 'CaffeineMark', 'CaffeineMark', 'Method.run2', false, 'CaffeineMark: Method'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'NumericSort.index', false, 'jBYTEmark: Numeric Sort'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'StringSort.index', false, 'jBYTEmark: String Sort'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'BitfieldOperations.index', false, 'jBYTEmark: Bitfield Operations'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'FPEmulation.index', false, 'jBYTEmark: FP Emulation'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Fourier.index', false, 'jBYTEmark: Fourier'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Assignment.index', false, 'jBYTEmark: Assignment'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'IDEAEncryption.index', false, 'jBYTEmark: IDEA Encryption'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'HuffmanCompression.index', false, 'jBYTEmark: Huffman Compression'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'NeuralNet.index', false, 'jBYTEmark: Neural Net'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'LUDecomposition.index', false, 'jBYTEmark: LU Decomposition'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'Integer.index', false, 'jBYTEmark: Integer'],
      [nil, 'production', 'default', 'jBYTEmark', 'jBYTEmark', 'FP.index', false, 'jBYTEmark: FP'],
      ].each do |r|
        StatisticsMap.create!(:test_run_name => r[0],
        :build_configuration_name => r[1],
        :test_configuration_name => r[2],
        :group_name => r[3],
        :test_case_name => r[4],
        :statistic_key => r[5],
        :less_is_more => r[6],
        :label => r[7])
      end
    end
  end

  def self.down
  end
end
