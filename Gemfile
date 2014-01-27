source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '~> 4.0.2'

# Use postgres as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# JSON serialization
gem 'active_model_serializers', '~> 0.9.0.alpha1'

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'quiet_assets'
  gem 'sprockets_better_errors'
  gem 'letter_opener'
  #gem 'rack-mini-profiler'
end

group :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'terminal-notifier-guard'
  # web mocking
  gem 'webmock'
  gem 'vcr'
  # code coverage
  gem 'simplecov'
  gem 'coveralls'
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

# Newrelic /newrelic
gem 'newrelic_rpm'

# HAML
gem 'haml'
gem 'haml-rails'

# ENV var management
gem 'figaro'

# XML parser
gem 'nokogiri'

# REST API
gem 'rest-client'

# UserAgent parser
gem 'useragent'

# geo sort
gem 'geocoder'

# markdown emails
gem 'maildown'
