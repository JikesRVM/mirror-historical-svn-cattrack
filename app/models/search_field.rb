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
  attr_reader :dimension, :name, :key, :options, :dimension_name

  def initialize(dimension,name,options = {})
    @dimension = dimension
    @name = name
    @dimension_name = dimension.name[0,dimension.name.length - 9]
    @key = "#{@dimension_name.tableize.singularize}_#{name}".to_sym
    @options = {:any => true, :size => 4, :multiple => true}
    @options.merge!(options)
  end

  def label_for(value)
    options[:labels] ? options[:labels][value.to_i] : value
  end
end
