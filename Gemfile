# frozen_string_literal: true

ruby '2.7.5'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sentry-sidekiq'

group :test do
  gem 'codecov', require: true
  gem 'rspec', require: 'spec'
  gem 'rspec_junit_formatter'
end
