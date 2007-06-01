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
  attr_reader :row, :column, :function, :data, :row_headers, :column_headers

  def initialize(row, column, function, data)
    @row, @column, @function, @data = row, column, function, data
    calc_headers
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
    @row_headers = rows.collect{|r| @row.label_for(r)}
    @column_headers = columns.collect{|r| @column.label_for(r)}
  end
end
