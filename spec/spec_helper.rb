# -*- ruby -*-

require 'pathname'
require 'simplecov' if ENV['COVERAGE']
require 'rspec'
require 'deprecatable'
require 'loggability/spechelpers'
require 'faker'

require 'chione'

Deprecatable.options.alert_frequency = :never
Deprecatable.options.has_at_exit_report = false

module Chione::TestHelpers
end


Faker::Config.locale = :en


RSpec.configure do |config|
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	SPEC_DIR = Pathname( __FILE__ ).dirname
	SPEC_DATA_DIR = SPEC_DIR + 'data'

	config.disable_monkey_patching!
	config.example_status_persistence_file_path = "spec/.status"
	config.filter_run :focus
	config.filter_run_when_matching :focus
	config.order = :random
	config.profile_examples = 5
	config.run_all_when_everything_filtered = true
	config.shared_context_metadata_behavior = :apply_to_host_groups
	# config.warnings = true

	config.include( Loggability::SpecHelpers )
	config.include( Chione::TestHelpers )
end


