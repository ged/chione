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
Hoe.plugins.delete :gemcutter

hoespec = Hoe.spec 'chione' do |spec|
	spec.readme_file = 'README.md'
	spec.history_file = 'History.md'
	spec.license 'BSD'

	spec.developer 'Michael Granger', 'ged@FaerieMUD.org'

	spec.dependency 'loggability',     '~> 0.11'
	spec.dependency 'configurability', '~> 2.2'
	spec.dependency 'uuid',            '~> 2.3'

	spec.dependency 'hoe-deveiate',            '~> 0.3',  :developer
	spec.dependency 'simplecov',               '~> 0.7',  :developer
	spec.dependency 'rdoc-generator-fivefish', '~> 0.1',  :developer

	spec.require_ruby_version( '>=2.2.1' )
	spec.hg_sign_tags = true if spec.respond_to?( :hg_sign_tags= )
	spec.check_history_on_release = true if spec.respond_to?( :check_history_on_release= )

	spec.rdoc_locations << "yhaliwell:/usr/local/www/public/chione/docs"
end



ENV['VERSION'] ||= hoespec.spec.version.to_s

# Ensure the specs pass before checking in
task 'hg:precheckin' => [ :check_history, :check_manifest, :gemspec, :spec ]

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
