# -*- encoding: utf-8 -*-
# stub: chione 0.1.0.pre20150713182712 ruby lib

Gem::Specification.new do |s|
  s.name = "chione"
  s.version = "0.1.0.pre20150713182712"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Michael Granger"]
  s.cert_chain = ["certs/ged.pem"]
  s.date = "2015-07-14"
  s.description = "An Entity/Component System framework inspired by Artemis.\n\nThis library is still experimental. I am writing it by extracting out ideas from\na multi-user game I'm working on, and things may change radically if I find\nthat parts of it don't work or could be done a better way.\n\nThat said, let me know if you're using it for anything and I'll try to keep\nyou abreast of any changes I'm considering, and I'm happy to chat about ideas\nfor making it better via email or the project's Gitter channel:\n\n{rdoc-image:https://badges.gitter.im/Join%20Chat.svg}[https://gitter.im/ged/chione]"
  s.email = ["ged@FaerieMUD.org"]
  s.extra_rdoc_files = ["History.rdoc", "Manifest.txt", "README.rdoc"]
  s.files = [".rdoc_options", ".simplecov", "ChangeLog", "History.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "lib/chione.rb", "lib/chione/aspect.rb", "lib/chione/assemblage.rb", "lib/chione/behaviors.rb", "lib/chione/component.rb", "lib/chione/entity.rb", "lib/chione/manager.rb", "lib/chione/mixins.rb", "lib/chione/system.rb", "lib/chione/world.rb", "spec/chione/aspect_spec.rb", "spec/chione/assemblage_spec.rb", "spec/chione/component_spec.rb", "spec/chione/entity_spec.rb", "spec/chione/manager_spec.rb", "spec/chione/mixins_spec.rb", "spec/chione/system_spec.rb", "spec/chione/world_spec.rb", "spec/chione_spec.rb", "spec/spec_helper.rb"]
  s.homepage = "http://faelidth.org/chione"
  s.licenses = ["BSD"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.1")
  s.rubygems_version = "2.4.7"
  s.summary = "An Entity/Component System framework inspired by Artemis"

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
