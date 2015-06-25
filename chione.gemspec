# -*- encoding: utf-8 -*-
# stub: chione 0.1.0.pre20150624172942 ruby lib

Gem::Specification.new do |s|
  s.name = "chione"
  s.version = "0.1.0.pre20150624172942"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.cert_chain = ["certs/ged.pem"]
  s.date = "2015-06-25"
  s.description = ""
  s.email = ["ged@FaerieMUD.org"]
  s.extra_rdoc_files = ["History.md", "Manifest.txt", "README.md"]
  s.files = [".simplecov", "ChangeLog", "History.md", "Manifest.txt", "README.md", "Rakefile", "lib/chione.rb", "lib/chione/aspect.rb", "lib/chione/assemblage.rb", "lib/chione/component.rb", "lib/chione/entity.rb", "lib/chione/manager.rb", "lib/chione/mixins.rb", "lib/chione/system.rb", "lib/chione/world.rb", "spec/chione/aspect_spec.rb", "spec/chione/assemblage_spec.rb", "spec/chione/component_spec.rb", "spec/chione/entity_spec.rb", "spec/chione/manager_spec.rb", "spec/chione/system_spec.rb", "spec/chione/world_spec.rb", "spec/chione_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "An Entity/Component System framework inspired by Artemis."
  s.licenses = ["BSD"]
  s.rdoc_options = ["--main", "README.md"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.1")
  s.rubygems_version = "2.4.7"
  s.summary = ""

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<loggability>, ["~> 0.11"])
      s.add_runtime_dependency(%q<configurability>, ["~> 2.2"])
      s.add_runtime_dependency(%q<uuid>, ["~> 2.3"])
      s.add_development_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_development_dependency(%q<hoe-deveiate>, ["~> 0.7"])
      s.add_development_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<loggability>, ["~> 0.11"])
      s.add_dependency(%q<configurability>, ["~> 2.2"])
      s.add_dependency(%q<uuid>, ["~> 2.3"])
      s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
      s.add_dependency(%q<hoe-deveiate>, ["~> 0.7"])
      s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<loggability>, ["~> 0.11"])
    s.add_dependency(%q<configurability>, ["~> 2.2"])
    s.add_dependency(%q<uuid>, ["~> 2.3"])
    s.add_dependency(%q<hoe-mercurial>, ["~> 1.4"])
    s.add_dependency(%q<hoe-deveiate>, ["~> 0.7"])
    s.add_dependency(%q<hoe-highline>, ["~> 0.2"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<rdoc-generator-fivefish>, ["~> 0.1"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
