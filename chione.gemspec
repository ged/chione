# -*- encoding: utf-8 -*-
# stub: chione 0.11.0.pre20190220083618 ruby lib

Gem::Specification.new do |s|
  s.name = "chione".freeze
  s.version = "0.11.0.pre20190220083618"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.cert_chain = ["certs/ged.pem".freeze]
  s.date = "2019-02-20"
  s.description = "An Entity/Component System framework inspired by Artemis.\n\nThis library is still experimental. I am writing it by extracting out ideas from\na multi-user game I'm working on, and things may change radically if I find\nthat parts of it don't work or could be done a better way.\n\nThat said, let me know if you're using it for anything and I'll try to keep\nyou abreast of any changes I'm considering, and I'm happy to chat about ideas\nfor making it better via email or whatever.".freeze
  s.email = ["ged@FaerieMUD.org".freeze]
  s.extra_rdoc_files = ["History.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "History.md".freeze, "README.md".freeze]
  s.files = [".rdoc_options".freeze, ".simplecov".freeze, "ChangeLog".freeze, "History.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "lib/chione.rb".freeze, "lib/chione/archetype.rb".freeze, "lib/chione/aspect.rb".freeze, "lib/chione/assemblage.rb".freeze, "lib/chione/behaviors.rb".freeze, "lib/chione/component.rb".freeze, "lib/chione/entity.rb".freeze, "lib/chione/fixtures.rb".freeze, "lib/chione/fixtures/entities.rb".freeze, "lib/chione/iterating_system.rb".freeze, "lib/chione/manager.rb".freeze, "lib/chione/mixins.rb".freeze, "lib/chione/system.rb".freeze, "lib/chione/world.rb".freeze, "spec/chione/archetype_spec.rb".freeze, "spec/chione/aspect_spec.rb".freeze, "spec/chione/component_spec.rb".freeze, "spec/chione/entity_spec.rb".freeze, "spec/chione/iterating_system_spec.rb".freeze, "spec/chione/manager_spec.rb".freeze, "spec/chione/mixins_spec.rb".freeze, "spec/chione/system_spec.rb".freeze, "spec/chione/world_spec.rb".freeze, "spec/chione_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "http://deveiate.org/projects/chione".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.0".freeze)
  s.rubygems_version = "3.0.2".freeze
  s.summary = "An Entity/Component System framework inspired by Artemis".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_runtime_dependency(%q<configurability>.freeze, ["~> 3.0"])
      s.add_runtime_dependency(%q<pluggability>.freeze, ["~> 0.4"])
      s.add_runtime_dependency(%q<uuid>.freeze, ["~> 2.3"])
      s.add_runtime_dependency(%q<deprecatable>.freeze, ["~> 1.0"])
      s.add_runtime_dependency(%q<fluent_fixtures>.freeze, ["~> 0.6"])
      s.add_runtime_dependency(%q<faker>.freeze, ["~> 1.8"])
      s.add_development_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_development_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.12"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.17"])
    else
      s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
      s.add_dependency(%q<configurability>.freeze, ["~> 3.0"])
      s.add_dependency(%q<pluggability>.freeze, ["~> 0.4"])
      s.add_dependency(%q<uuid>.freeze, ["~> 2.3"])
      s.add_dependency(%q<deprecatable>.freeze, ["~> 1.0"])
      s.add_dependency(%q<fluent_fixtures>.freeze, ["~> 0.6"])
      s.add_dependency(%q<faker>.freeze, ["~> 1.8"])
      s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
      s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
      s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
      s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
    end
  else
    s.add_dependency(%q<loggability>.freeze, ["~> 0.12"])
    s.add_dependency(%q<configurability>.freeze, ["~> 3.0"])
    s.add_dependency(%q<pluggability>.freeze, ["~> 0.4"])
    s.add_dependency(%q<uuid>.freeze, ["~> 2.3"])
    s.add_dependency(%q<deprecatable>.freeze, ["~> 1.0"])
    s.add_dependency(%q<fluent_fixtures>.freeze, ["~> 0.6"])
    s.add_dependency(%q<faker>.freeze, ["~> 1.8"])
    s.add_dependency(%q<hoe-mercurial>.freeze, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>.freeze, ["~> 0.10"])
    s.add_dependency(%q<hoe-highline>.freeze, ["~> 0.2"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.12"])
    s.add_dependency(%q<rdoc-generator-fivefish>.freeze, ["~> 0.4"])
    s.add_dependency(%q<rdoc>.freeze, [">= 4.0", "< 7"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.17"])
  end
end
