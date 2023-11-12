# frozen_string_literal: true

require 'pathname'
require 'date'
require_relative 'lib/remotelock-sdk/defs/version'

Gem::Specification.new do |gem|
  gem.name          = 'remotelock-sdk'
  gem.version       = RL_SDK_VERSION

  gem.summary       = 'SDK for RemoteLock API v1'
  gem.description   = 'SDK for RemoteLock (remotelock.com) API v1 '

  gem.authors       = ['Morgan Sziraki']
  gem.email         = 'morgan@morganism.dev'
  gem.homepage      = 'https://git.morganism.dev/remotelock-sdk'
  gem.license       = 'BSD-2-Clause'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.require_paths = %w[lib]
  gem.bindir        = 'bin'

  gem.add_dependency 'addressable', '~> 2.8'
  gem.add_dependency 'faraday', '~> 1.1'
  gem.add_dependency 'inifile', '~> 3.0'
  gem.add_dependency 'map', '~> 6.6'

  gem.add_development_dependency 'minitest', '~> 5.17'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rubocop', '~> 1.43'
  gem.add_development_dependency 'rubocop-minitest', '~> 0.26'
  gem.add_development_dependency 'rubocop-performance', '~> 1.15'
  gem.add_development_dependency 'rubocop-rake', '~> 0.6'
  gem.add_development_dependency 'simplecov', '~> 0.18'
  gem.add_development_dependency 'spy', '1.0'
  gem.add_development_dependency 'webmock', '~> 3.18'
  gem.add_development_dependency 'yard', '~> 0.9'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
