# -*- ruby -*-
# encoding: utf-8
# frozen_string_literal: true

require 'faker'
require 'fluent_fixtures'

require 'chione' unless defined?( Chione )


module Chione::Fixtures
	extend FluentFixtures::Collection

	# Set the path to use when finding fixtures for this collection
	fixture_path_prefix 'chione/fixtures'

end # module Chione

