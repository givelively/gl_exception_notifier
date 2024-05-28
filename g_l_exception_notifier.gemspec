Gem::Specification.new do |s|
  s.name = 'g_l_exception_notifier'
  s.version = '1.0.0'
  s.summary = "A wrapper for GiveLively's exception notifier"
  s.authors = ['Give Lively', 'Tim Lawrenz', 'Joe Anzalone', 'Dave Urban']
  s.description = "To avoid having to update exception notifiers in all the different repositories,
    we pull out commonalities and wrap them into gems"
  s.required_ruby_version = '>= 3.1'

  s.email = 'tim@givelively.org'
  s.files = ['lib/g_l_exception_notifier.rb']
  s.require_paths = ['lib']
  s.homepage = 'https://github.com/givelively/g_l_exception_notifier/'

  s.add_dependency 'sentry-ruby'
  s.add_dependency 'sentry-rails'
  s.add_dependency 'sentry-sidekiq'
  s.add_development_dependency 'rspec', '~> 3.11.0'
  s.add_development_dependency 'rspec_junit_formatter'
  s.add_development_dependency 'g_l_lint'

  s.metadata['rubygems_mfa_required'] = 'true'
end
