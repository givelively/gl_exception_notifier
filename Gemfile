# frozen_string_literal: true

ruby '2.7.5'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'sentry-ruby'
gem 'sentry-rails'

group :test, :development do
  gem 'codecov'
  gem 'rspec', require: 'spec'
end
