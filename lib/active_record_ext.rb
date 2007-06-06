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
module ActiveRecord
  class Base
    def self.label
      self.name.humanize
    end

    def self.validates_positive(name, options={})
      configuration = {:message => 'must be positive.', :on => :save}
      configuration.update(options)
      validates_each([name], configuration) do |record, attr_name, value|
        value = record.send(attr_name)
        record.errors.add(attr_name, configuration[:message]) if (not value.nil? and value < 0)
      end
    end

    def self.validates_non_presence_of(name, options={})
      configuration = {:message => 'must be blank.', :on => :save}
      configuration.update(options)
      validates_each([name], configuration) do |record, attr_name, value|
        value = record.send(attr_name)
        record.errors.add(attr_name, configuration[:message]) unless value.blank?
      end
    end

    def self.validates_not_null(name, options={})
      configuration = {:message => ActiveRecord::Errors.default_error_messages[:blank], :on => :save}
      configuration.update(options)
      validates_each([name], configuration) do |record, attr_name, value|
        value = record.send(attr_name)
        record.errors.add(attr_name, configuration[:message]) if value.nil?
      end
    end

    def label
      if self.respond_to?(:name)
        self.name
      else
        self.to_s
      end
    end
  end
end