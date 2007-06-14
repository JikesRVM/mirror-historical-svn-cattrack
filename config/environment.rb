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
# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/services )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc

  # Turn of ascii coloring of logs
  config.active_record.colorize_logging = false

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

require 'digest/sha1' # used when hashing passwords
require 'active_record_ext' # My custom extension to ar for labels etc
require 'param_helper' # For custom has_params extension
require 'rexml/document' # For parsing uploaded xml files
require 'routing_ext' # Monkey patch routing to remove . as a separator
require 'no_cache' # Add in method to force no caching on the client.

OrderedTables = [
'system_settings',

'users',
'hosts',
'test_runs',
'build_configurations', 'build_configuration_params', 'build_configuration_outputs',
'build_targets', 'build_target_params',
'test_configurations', 'test_configuration_params',
'groups',
'test_cases','test_case_outputs','test_case_statistics',
'result_dimension',
'host_dimension',
'build_configuration_dimension',
'build_target_dimension',
'test_configuration_dimension',
'test_case_dimension',
'time_dimension',
'revision_dimension',
'statistic_dimension',
'test_run_dimension',
'result_facts',
'statistic_facts',
'filters', 'filter_params',
'summarizers',
'data_presentations', 'data_presentation_params',
'data_views',
'measures',
]

import_logger = Logger.new("#{File.expand_path(RAILS_ROOT)}/log/importer.log")
import_logger.level = (RAILS_ENV == 'production') ? Logger::INFO : Logger::DEBUG

TestRunImporter.logger = import_logger
TestRunBuilder.logger = import_logger

LocalConfig = File.join(File.dirname(__FILE__), 'local')
require LocalConfig if File.exist?("#{LocalConfig}.rb")

