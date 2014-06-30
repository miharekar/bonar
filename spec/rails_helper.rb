# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Automigrate if needs migration
if ActiveRecord::Migrator.needs_migration?
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths.first, nil)
end

# Disable any external requests
WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.before(:suite) { FactoryGirl.reload }
  config.include FactoryGirl::Syntax::Methods
  config.infer_spec_type_from_file_location!
end
