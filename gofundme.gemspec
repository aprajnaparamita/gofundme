
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gofundme/version"

Gem::Specification.new do |spec|
  spec.name          = "gofundme"
  spec.version       = Gofundme::VERSION
  spec.authors       = ["Janet Jeffus"]
  spec.email         = ["speak@jjeff.us"]

  spec.summary       = %q{Access data from GoFundMe.com site}
  spec.description   = %q{A library to scrape GoFundMe.com donation campaigns (called Projects). GoFundMe does not have a publicly available API to query about donation lists, so this library scrapes information from GoFundMe's own mvc.php API using rest_client. This library is liable to break if GFM changes their API consumption endpoints. This Library is not associated to GoFundMe, Inc. in any way, shape, or form and respects robots.txt.}
  spec.homepage      = "https://github.com/jjeffus/gofundme"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/jjeffus/gofundme"
    spec.metadata["changelog_uri"] = "https://github.com/jjeffus/gofundme/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "nokogiri"
  spec.add_dependency "rest-client", ">= 1.8.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
