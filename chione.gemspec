# -*- encoding: utf-8 -*-
# stub: chione 0.13.0.pre.20230510000839 ruby lib

Gem::Specification.new do |s|
  s.name = "chione".freeze
  s.version = "0.13.0.pre.20230510000839"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://todo.sr.ht/~ged/chione", "documentation_uri" => "https://faelidth.org/chione/docs", "homepage_uri" => "https://faelidth.org/chione", "source_uri" => "https://hg.sr.ht/~ged/chione" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Granger".freeze]
  s.date = "2023-05-10"
  s.description = "An Entity/Component System framework inspired by Artemis.".freeze
  s.email = ["ged@faeriemud.org".freeze]
  s.files = [".rdoc_options".freeze, ".simplecov".freeze, "ChangeLog".freeze, "History.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "Rakefile".freeze, "lib/chione.rb".freeze, "lib/chione/archetype.rb".freeze, "lib/chione/aspect.rb".freeze, "lib/chione/assemblage.rb".freeze, "lib/chione/behaviors.rb".freeze, "lib/chione/component.rb".freeze, "lib/chione/entity.rb".freeze, "lib/chione/fixtures.rb".freeze, "lib/chione/fixtures/entities.rb".freeze, "lib/chione/iterating_system.rb".freeze, "lib/chione/manager.rb".freeze, "lib/chione/mixins.rb".freeze, "lib/chione/system.rb".freeze, "lib/chione/world.rb".freeze, "spec/chione/archetype_spec.rb".freeze, "spec/chione/aspect_spec.rb".freeze, "spec/chione/component_spec.rb".freeze, "spec/chione/entity_spec.rb".freeze, "spec/chione/iterating_system_spec.rb".freeze, "spec/chione/manager_spec.rb".freeze, "spec/chione/mixins_spec.rb".freeze, "spec/chione/system_spec.rb".freeze, "spec/chione/world_spec.rb".freeze, "spec/chione_spec.rb".freeze, "spec/spec_helper.rb".freeze]
  s.homepage = "https://faelidth.org/chione".freeze
  s.licenses = ["BSD-3-Clause".freeze]
  s.rubygems_version = "3.4.12".freeze
  s.summary = "An Entity/Component System framework inspired by Artemis.".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<loggability>.freeze, ["~> 0.17"])
  s.add_runtime_dependency(%q<configurability>.freeze, ["~> 4.0"])
  s.add_runtime_dependency(%q<pluggability>.freeze, ["~> 0.4"])
  s.add_runtime_dependency(%q<uuid>.freeze, ["~> 2.3"])
  s.add_runtime_dependency(%q<deprecatable>.freeze, ["~> 1.0"])
  s.add_runtime_dependency(%q<fluent_fixtures>.freeze, ["~> 0.11"])
  s.add_runtime_dependency(%q<faker>.freeze, ["~> 3.2"])
  s.add_development_dependency(%q<rake-deveiate>.freeze, ["~> 0.22"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.12"])
  s.add_development_dependency(%q<rdoc-generator-sixfish>.freeze, ["~> 0.3"])
end
