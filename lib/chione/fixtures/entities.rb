# -*- ruby -*-

require 'faker'

require 'chione/fixtures' unless defined?( Chione::Fixtures )
require 'chione/entity'


# Entity fixtures
module Chione::Fixtures::Entities
	extend Chione::Fixtures

	fixtured_class Chione::Entity

	base :entity

	decorator :with_id do |id|
		@id = id
	end


	decorator :with_components do |*components|
		components.each do |comp|
			self.add_component( comp )
		end
	end

end # module Chione::Fixtures::Entities



