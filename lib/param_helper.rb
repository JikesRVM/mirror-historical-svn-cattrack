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

#
# This class adds a has_params method to ActiveRecord::Base
# that makes it possible to have a relationship between the
# type and another ""property bag"" table. The Property Bag
# table must have three columns;
#
# * owner_id: foreign key into current table (int)
# * unique: identifier for property (String)
# * value: the value of property
#
class Params
  def initialize(owner, table_name)
    @owner = owner
    @table_name = table_name
  end

  def [](key)
    values[key]
  end

  def []=(key, value)
    if value.nil?
      values.delete(key)
    else
      values[key] = value
    end

    @modified = true
  end

  def each_pair(&block)
    values.each_pair do |k, v|
      block.call(k, v)
    end
  end

  def length
    values.size
  end

  def size
    values.size
  end

  def empty?
    size.zero?
  end

  def clear
    @values = {}
    @modified = true
  end

  def values(reload = false)
    if (reload or not @values)
      @values = {}
      sql = "SELECT key, value FROM #{@table_name} WHERE owner_id = #{@owner.id}"
      @owner.connection.select_all(sql).each do |row|
        key = row['key']
        value = row['value']
        if @values[key].nil?
          @values[key] = value
        elsif @values[key].is_a?(Array)
          @values[key] << value
        else
          @values[key] = [@values[key], value]
        end
      end unless @owner.new_record?
    end
    @values
  end

  def save!
    if @modified
      @owner.connection.execute("DELETE FROM #{@table_name} WHERE owner_id = #{@owner.id}")
      @values.each_pair do |k, v|
        v = v.is_a?(Array) ? v : [v]
        v.each do |value|
          sql =
          "INSERT INTO #{@table_name} (owner_id,key,value) " +
          "VALUES (#{@owner.id},#{ActiveRecord::Base.quote_value(k)},#{ActiveRecord::Base.quote_value(value)})"
          @owner.connection.execute(sql)
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do

  def self.has_params(name, options = {})
    table_name = (self.table_name.singularize + '_' + name.to_s).pluralize
    define_method(name) do |*params|
      force_reload = params.first unless params.empty?
      association = instance_variable_get("@#{name}")
      if association.nil? || force_reload
        association = Params.new(self, table_name)
        instance_variable_set("@#{name}", association)
      end
      association
    end

    module_eval do
      after_save <<-EOF
        association = instance_variable_get("@#{name}")
        association.save! if association
      EOF
    end
  end

end