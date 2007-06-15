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
class Olap::Query::Report < ActiveRecord::Base
  validates_length_of :name, :in => 1..120
  validates_uniqueness_of :name
  validates_length_of :description, :in => 0..256
  validates_presence_of :query_id, :presentation_id
  validates_reference_exists :query_id, Olap::Query::Query
  validates_reference_exists :presentation, Olap::Query::Presentation

  validates_each(:presentation_id) do |record, attr, value|
    if (not record.query.nil? and record.query.measure.presentations.find_by_id(record.presentation_id).nil?)
      record.errors.add(attr, 'presentation not applicable for measure.')
    end
  end

  belongs_to :query, :class_name => 'Olap::Query::Query', :foreign_key => 'query_id'
  belongs_to :presentation, :class_name => 'Olap::Query::Presentation', :foreign_key => 'presentation_id'
end
