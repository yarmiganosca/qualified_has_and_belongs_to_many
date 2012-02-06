# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "qualified_has_and_belongs_to_many/version"

Gem::Specification.new do |s|
  s.name        = "qualified_has_and_belongs_to_many"
  s.version     = QualifiedHasAndBelongsToMany::VERSION
  s.authors     = ["Chris Hoffman"]
  s.email       = ["choffman@beechstcap.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "qualified_has_and_belongs_to_many"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'active_record', '>= 3.1'
end
