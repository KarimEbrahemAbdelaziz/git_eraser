lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "git_eraser/version"

Gem::Specification.new do |spec|
  spec.name          = "git_eraser"
  spec.version       = GitEraser::VERSION
  spec.authors       = ["KarimEbrahem"]
  spec.email         = ["karimabdelazizmansour@gmail.com"]

  spec.summary = 'git_eraser is used to help you in cleaning your git branches.'
  spec.description = 'git_eraser is used to help you in cleaning your branches.'
  spec.homepage      = "https://github.com/KarimEbrahemAbdelaziz/git_eraser"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://RubyGems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/KarimEbrahemAbdelaziz/git_eraser"
    spec.metadata["changelog_uri"] = "https://github.com/KarimEbrahemAbdelaziz/git_eraser"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.bindir        = "exe"
  spec.executables   = ["git_eraser"]
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.20.3"
  spec.add_dependency "highline", "~> 2.0.2"
  spec.add_dependency "rainbow", "~> 3.0.0"
  spec.add_dependency "git", "~> 1.5.0"
  spec.add_dependency "httpclient", "~> 2.8.3"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
