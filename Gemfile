source 'https://rubygems.org'

ruby '2.1.5'

gem 'rails', '~> 4.1.7'

# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# JSON serialization
gem 'active_model_serializers'

# HAML
gem 'haml'
gem 'haml-rails'

# ENV var management
gem 'figaro'

# XML parser
gem 'nokogiri'

# geo sort
gem 'geocoder'

# markdown emails
gem 'maildown'

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
  # caching
  gem 'memcachier'
  gem 'dalli'
end

group :production, :development do
  # Newrelic /newrelic
  gem 'newrelic_rpm'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'quiet_assets'
  gem 'letter_opener'
  #gem 'rack-mini-profiler'
end

group :development, :test do
  # App preloading
  gem 'spring'
  gem 'spring-commands-rspec'
  # Pry stuff
  gem 'pry'
  gem 'pry-coolline'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'hirb'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  # web mocking
  gem 'webmock'
  gem 'vcr'
end
