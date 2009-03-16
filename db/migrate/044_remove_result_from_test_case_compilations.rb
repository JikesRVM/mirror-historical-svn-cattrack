class RemoveResultFromTestCaseCompilations < ActiveRecord::Migration
  def self.up
      remove_column :test_case_compilations, :result
      remove_column :test_case_compilations, :exit_code
  end

  def self.down
      add_column :test_case_compilations, :result, :string, :limit => 15, :null => false
      add_column :test_case_compilations, :exit_code, :integer, :null => false
  end
end
