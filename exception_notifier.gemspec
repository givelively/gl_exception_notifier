Gem::Specification.new do |s|
  s.name = 'exception_notifier'
  s.version = '0.1.10'
  s.summary = "A wrapper for GiveLively's exception notifier"
  s.authors = ['Tim Lawrenz', 'Joe Anzalone', 'Dave Urban']
  s.date = '2022-02-08'
  s.description = "To avoid having to update exception notifiers in all the different repositories,
    we pull out commonalities and wrap them into gems"
  s.email = 'tim@givelively.org'
  s.files = ['lib/exception_notifier.rb']
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/givelively/exception_notifier/'

  s.add_dependency 'sentry-ruby'
  s.add_dependency 'sentry-rails'
  s.add_dependency 'sentry-sidekiq'
  s.add_development_dependency 'rspec', '~> 3.8.0'
  s.add_development_dependency 'rspec_junit_formatter'
end
