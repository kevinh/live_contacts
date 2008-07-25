Gem::Specification.new do |s|
  s.name = %q{live_contacts}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kenneth Lee"]
  s.date = %q{2008-07-25}
  s.description = %q{FIX (describe your package)}
  s.email = %q{kenfodder@gmail.com}
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/live_contacts.rb", "test/test_live_contacts.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{live_contacts}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{FIX (describe your package)}
  s.test_files = ["test/test_live_contacts.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<ruby-openid>, ["= 1.1.4"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<ruby-openid>, ["= 1.1.4"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<ruby-openid>, ["= 1.1.4"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
