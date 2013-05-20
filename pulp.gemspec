# -*- encoding: utf-8 -*-
require File.expand_path('../lib/pulp/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'pulp'
  s.version = Pulp::VERSION

  s.authors = ['mh']
  s.description = %q{A little ruby wrapper around the pulp (http://pulpproject.org) API}
  s.email = 'mh@immerda.ch'
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = Dir['lib/**/*.rb']
  s.homepage = 'https://github.com/duritong/ruby-pulp'
  s.licenses = ['MIT']
  s.require_paths = ['lib']
  s.summary = %q{A little ruby wrapper around the pulp API}

  s.add_runtime_dependency('rest-client', '~> 1.6.7')
  s.add_runtime_dependency('activesupport', '~> 3.2.12')
  s.add_runtime_dependency('json', '~> 1.8.0')
  s.add_runtime_dependency('i18n', '~> 0.6.4')
  s.add_development_dependency('rspec', '~> 2.13.0')
  s.add_development_dependency('jeweler', '~> 1.6.4')
  s.add_development_dependency('rcov', '~> 1.0.0') if RUBY_VERSION < '1.9.0'
  s.add_development_dependency('simplecov', '~> 0.7.1')
  s.add_development_dependency('mocha', '~> 0.14.0')

end

