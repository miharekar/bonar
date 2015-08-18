source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '~> 4.2.1'
gem 'figaro'
gem 'pg'
gem 'active_model_serializers'
gem 'nokogiri'
gem 'geocoder'

gem 'sass-rails', '~> 5.0'
gem 'uglifier'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'slim-rails'
gem 'maildown'

group :production do
  gem 'puma'
  gem 'rails_12factor'
  gem 'memcachier'
  gem 'dalli'
end

group :production, :development do
  gem 'newrelic_rpm'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'bullet'
  gem 'quiet_assets'
  gem 'letter_opener'
  gem 'rack-mini-profiler'
end

group :development, :test do
  gem 'spring'
  gem 'spring-commands-rspec'
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
  gem 'webmock'
  gem 'vcr'
end
