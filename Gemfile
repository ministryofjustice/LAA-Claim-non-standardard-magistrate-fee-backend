source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read('.ruby-version').strip

gem 'aws-sdk-s3', '~> 1.177'
gem 'bootsnap', '~> 1.18.4', require: false
gem 'clamby', '~> 1.6'
gem 'cssbundling-rails'
gem 'devise', '~> 4.8'
gem 'factory_bot_rails', '>= 6.4.3'
gem 'faker'
gem 'govuk-components', '>= 5.0.0'
gem 'govuk_design_system_formbuilder', '>= 5.4', '< 5.9'
gem 'govuk_notify_rails', '~> 3.0.0'
gem 'grover'
gem 'httparty'
gem 'jsbundling-rails'
gem 'laa_crime_forms_common', '~> 0.9.0', github: 'ministryofjustice/laa-crime-forms-common'
gem 'lograge'
gem 'logstasher', '~> 2.1'
gem 'logstash-event'
gem 'marcel'
gem 'oauth2', '~> 2.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0.1'
gem 'omniauth-saml', '>= 2.1', '< 2.3'
gem 'ostruct'
gem 'pagy', '~> 9.3.3'
gem 'pg', '~> 1.5'
gem 'prometheus_exporter'
gem 'propshaft'
gem 'puma', '~> 6.5.0'
gem 'rails', '~> 8.0.1'
gem 'redis'
gem 'sentry-rails', '~> 5.22.1'
gem 'sentry-ruby', '~> 5.22.0'
gem 'sidekiq', '~> 7.3'
gem 'sidekiq_alive', '~> 2.4'
gem 'sidekiq-cron'
gem 'solid_cache', '~> 1.0'
gem 'table_print'
gem 'turbo-rails', '~> 2.0.11'
gem 'tzinfo-data'
gem 'uk_postcode'
gem 'with_advisory_lock'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'dotenv-rails'
  gem 'erb_lint', '>= 0.6.0', require: false
  gem 'overcommit'
  gem 'pry'
  gem 'rspec-expectations'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails', '~> 7.1.0'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'axe-core-rspec'
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rubocop', '>= 1.65.1', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', '>= 2.25.1', require: false
  gem 'rubocop-rspec', require: false
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'super_diff'
  gem 'webmock', '~> 3.24'
end
