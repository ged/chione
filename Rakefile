#!/usr/bin/env rake

require 'rake/clean'

begin
	require 'hoe'
rescue LoadError
	abort "This Rakefile requires 'hoe' (gem install hoe)"
end

GEMSPEC = 'chione.gemspec'


Hoe.plugin :mercurial
Hoe.plugin :signing
Hoe.plugin :deveiate

Hoe.plugins.delete :rubyforge

hoespec = Hoe.spec 'chione' do |spec|
	spec.readme_file = 'README.md'
	spec.history_file = 'History.md'
	spec.extra_rdoc_files = FileList[ '*.rdoc', '*.md' ]
	spec.license 'BSD-3-Clause'
	spec.urls = {
		home:   'http://deveiate.org/projects/LinguaThauma',
		code:   'http://repo.deveiate.org/LinguaThauma',
		docs:   'http://deveiate.org/code/LinguaThauma',
		github: 'http://github.com/ged/LinguaThauma',
	}

	spec.developer 'Michael Granger', 'ged@FaerieMUD.org'

	spec.dependency 'loggability',     '~> 0.12'
	spec.dependency 'configurability', '~> 3.0'
	spec.dependency 'pluggability',    '~> 0.4'
	spec.dependency 'uuid',            '~> 2.3'
	spec.dependency 'deprecatable',    '~> 1.0'

	spec.dependency 'hoe-deveiate',            '~> 1.0',  :developer
	spec.dependency 'simplecov',               '~> 0.12',  :developer
	spec.dependency 'rdoc-generator-fivefish', '~> 0.3',  :developer
	spec.dependency 'rdoc',                    '~> 5.1',  :developer

	spec.require_ruby_version( '>=2.3.3' )
	spec.hg_sign_tags = true if spec.respond_to?( :hg_sign_tags= )
	spec.check_history_on_release = true if spec.respond_to?( :check_history_on_release= )

	spec.rdoc_locations << "yhaliwell:/usr/local/www/public/chione/docs"
end



ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :gemspec, :spec ]

task :test => :spec

# Rebuild the ChangeLog immediately before release
task :prerelease => 'ChangeLog'
CLOBBER.include( 'ChangeLog' )

desc "Build a coverage report"
task :coverage do
	ENV["COVERAGE"] = 'yes'
	Rake::Task[:spec].invoke
end
CLOBBER.include( 'coverage' )


# Use the fivefish formatter for docs generated from development checkout
if File.directory?( '.hg' )
	require 'rdoc/task'

	Rake::Task[ 'docs' ].clear
	RDoc::Task.new( 'docs' ) do |rdoc|
	    rdoc.main = "README.md"
		rdoc.markup = 'markdown'
	    rdoc.rdoc_files.include( "*.md", "ChangeLog", "lib/**/*.rb" )
	    rdoc.generator = :fivefish
		rdoc.title = 'Chione'
	    rdoc.rdoc_dir = 'doc'
	end
end


task :gemspec => GEMSPEC
file GEMSPEC => __FILE__
task GEMSPEC do |task|
	Rake.application.trace "Updating gemspec"
	spec = $hoespec.spec
	spec.files.delete( '.gemtest' )
	spec.signing_key = nil
	spec.cert_chain = ['certs/ged.pem']
	spec.version = "#{spec.version.bump}.0.pre#{Time.now.strftime("%Y%m%d%H%M%S")}"
	File.open( task.name, 'w' ) do |fh|
		fh.write( spec.to_ruby )
	end
end

CLOBBER.include( GEMSPEC.to_s )

