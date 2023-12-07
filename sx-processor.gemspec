# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'sx-processor'
  spec.version       = '0.1.0'
  spec.authors       = ['Omar Luq']
  spec.email         = ['omaralanii@outlook.com']

  spec.summary       = 'processes SLIM templates and converts them into Ruby code'
  spec.description   = 'processes SLIM templates and converts them into Ruby code'
  spec.homepage      = 'http://github.com/omarluq/sx-processor'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.6.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slim'
  spec.add_dependency 'sorbet-runtime'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
