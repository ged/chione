#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/assemblage'
require 'chione/component'
require 'chione/entity'
require 'chione/world'

describe Chione::Assemblage do

	let( :world ) { Chione::World.new }

	let( :location_component ) do
		Class.new( Chione::Component ) do
			field :x, default: 0
			field :y, default: 0
		end
	end

	let( :tags_component ) do
		Class.new( Chione::Component ) do
			field :tags, default: []
		end
	end


	it "acts as a factory for entities with pre-set components" do
		assemblage = Module.new
		assemblage.extend( described_class )
		assemblage.add( location_component, x: 10, y: 8 )
		assemblage.add( tags_component, tags: [:foo, :bar] )

		entity = assemblage.construct_for( world )

		expect( entity ).to be_a( Chione::Entity )
		expect( entity.world ).to be( world )
		expect( entity.components ).to include( location_component, tags_component )
	end


	it "can include other assemblages" do
		general_assemblage = Module.new
		general_assemblage.extend( described_class )
		general_assemblage.add( location_component, x: 10, y: 8 )

		specific_assemblage = Module.new
		specific_assemblage.extend( described_class )
		specific_assemblage.send( :include, general_assemblage )
		specific_assemblage.add( tags_component, tags: [:foo, :bar] )

		entity = specific_assemblage.construct_for( world )

		expect( entity ).to be_a( Chione::Entity )
		expect( entity.world ).to be( world )
		expect( entity.components ).to include( location_component, tags_component )
	end

end

