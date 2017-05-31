#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/archetype'
require 'chione/component'
require 'chione/entity'
require 'chione/world'

describe Chione::Archetype do

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
		archetype = Module.new
		archetype.extend( described_class )
		archetype.add( location_component, x: 10, y: 8 )
		archetype.add( tags_component, tags: [:foo, :bar] )

		entity = archetype.construct_for( world )

		expect( entity ).to be_a( Chione::Entity )
		expect( entity.world ).to be( world )
		expect( entity.components ).to include( location_component, tags_component )
	end


	it "can include other archetypes" do
		general_archetype = Module.new
		general_archetype.extend( described_class )
		general_archetype.add( location_component, x: 10, y: 8 )

		specific_archetype = Module.new
		specific_archetype.extend( described_class )
		specific_archetype.send( :include, general_archetype )
		specific_archetype.add( tags_component, tags: [:foo, :bar] )

		entity = specific_archetype.construct_for( world )

		expect( entity ).to be_a( Chione::Entity )
		expect( entity.world ).to be( world )
		expect( entity.components ).to include( location_component, tags_component )
	end


	it "is still loadable as an `Assemblage`" do
		expect( Chione::Assemblage ).to equal( described_class )
	end


	it "still looks in the chione/assemblage directory for derivatives" do
		expect( described_class.plugin_prefixes ).to include( 'chione/assemblage' )
	end

end

