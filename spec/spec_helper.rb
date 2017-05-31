# -*- ruby -*-
#encoding: utf-8

require 'pathname'
require 'simplecov' if ENV['COVERAGE']
require 'rspec'
require 'deprecatable'
require 'loggability/spechelpers'

require 'chione'

Deprecatable.options.alert_frequency = :never
Deprecatable.options.has_at_exit_report = false

module Chione::TestHelpers
end



RSpec.configure do |config|
	# include Chione::TestHelpers

	SPEC_DIR = Pathname( __FILE__ ).dirname
	SPEC_DATA_DIR = SPEC_DIR + 'data'

	config.run_all_when_everything_filtered = true
	config.filter_run :focus
	config.order = 'random'
	config.mock_with( :rspec ) do |mock|
		mock.syntax = :expect
	end

	config.include( Loggability::SpecHelpers )
	config.include( Chione::TestHelpers )
end


