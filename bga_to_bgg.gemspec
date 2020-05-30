# frozen_string_literal: true

require_relative 'lib/bga_to_bgg/version'

Gem::Specification.new do |spec|
  spec.name          = 'bga_to_bgg'
  spec.version       = BgaToBgg::VERSION
  spec.authors       = ['Grégoire Seux']
  spec.email         = ['grego_rubygems@familleseux.net']

  spec.summary       = 'Sync boardgamearena play record to boardgamegeek'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'

  spec.add_runtime_dependency 'httpclient'
end
