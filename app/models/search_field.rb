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
class SearchField
  attr_reader :dimension, :name, :key, :key_name, :options, :dimension_name, :label

  def initialize(dimension,name,options = {})
    @dimension = dimension
    @name = name
    @dimension_name = dimension.name[0,dimension.name.length - 9]
    @key = "#{@dimension_name.tableize.singularize}_#{name}".to_sym
    @key_name = @key.to_s
    @options = {:any => true, :size => 4, :multiple => true}
    @options.merge!(options)
    @label = "#{@dimension_name.tableize.singularize.humanize} #{@name.to_s.humanize}"
  end

  def label_for(value)
    options[:labels] ? options[:labels][value.to_i] : value
  end
end
