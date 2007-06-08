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
class ReportResultData
  attr_reader :sql, :row, :column, :function, :data, :row_headers, :column_headers

  def initialize(sql, row, column, function, data)
    @sql, @row, @column, @function, @data = sql, row, column, function, data
    calc_headers
  end

  def tabular_data
    unless @tabular_data
      @tabular_data = []
      index = 0
      0.upto(row_headers.size - 1) do |r_index|
        @tabular_data[r_index] = []
        0.upto(column_headers.size - 1) do |c_index|
          if ((index < @data.size) and (@row_headers[r_index] == @data[index]['row']) and (@column_headers[c_index] == @data[index]['column']))
            data = @data[index].dup
            index += 1
            data.delete('row')
            data.delete('column')
            @tabular_data[r_index][c_index] = (data.size == 1) ? data.values[0] : data
          else
            @tabular_data[r_index][c_index] = nil
          end
        end
      end
    end
    @tabular_data
  end

  private

  def calc_headers
    rows, columns = [], []
    @data.each do |row|
      c = row['column']
      columns << c unless columns.include?(c)
      r = row['row']
      rows << r unless rows.include?(r)
    end
    @row_headers = rows
    @column_headers = columns
  end
end
