#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/aspect'
require 'chione/component'
require 'chione/fixtures'


describe Chione::Aspect do

	before( :all ) do
		Chione::Fixtures.load( :entities )
	end


	let( :location ) do
		Class.new( Chione::Component ) do
			field :x, default: 0
			field :y, default: 0
			def self::name; "Location"; end
		end
	end

	let( :tags ) do
		Class.new( Chione::Component ) do
			field :tags, default: []
			def self::name; "Tags"; end
		end
	end

	let( :color ) do
		Class.new( Chione::Component ) do
			field :hue, default: 0
			field :shade, default: 0
			field :value, default: 0
			field :opacity, default: 0
			def self::name; "Color"; end
		end
	end

	let( :world ) { Chione::World.new }

	let( :entity ) { Chione::Fixtures.entity(world) }
	let( :entity1 ) do
		entity.with_components( location ).instance
	end
	let( :entity2 ) do
		entity.with_components( location, color ).instance
	end
	let( :entity3 ) do
		entity.with_components( location, color, tags ).instance
	end
	let( :entity4 ) do
		entity.with_components( color, tags ).instance
	end
	let( :entity5 ) do
		entity.with_components( tags ).instance
	end


	it "doesn't have any default criteria" do
		aspect = described_class.new
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of ).to be_empty
		expect( aspect.none_of ).to be_empty
		expect( aspect ).to be_empty
	end


	it "can be created with default criteria" do
		aspect = described_class.with_all_of( tags, location )
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
		expect( aspect.none_of ).to be_empty
	end


	it "can make a clone of itself with additional one_of criteria" do
		aspect = described_class.new
		clone = aspect.with_one_of( location, tags )
		expect( clone ).to_not be( aspect )
		expect( clone.one_of ).to include( location, tags )
		expect( aspect.one_of ).to be_empty
	end


	it "can make a clone of itself with additional none_of criteria" do
		aspect = described_class.with_none_of( location )
		clone = aspect.with_none_of( tags )
		expect( clone ).to_not be( aspect )
		expect( clone.none_of ).to include( location, tags )
		expect( aspect.none_of.size ).to eq( 1 )
		expect( aspect.none_of ).to include( location )
	end


	it "can make a clone of itself with additional all_of criteria" do
		aspect = described_class.with_all_of( color, location )
		clone = aspect.with_all_of( tags )
		expect( clone ).to_not be( aspect )
		expect( clone.all_of.size ).to eq( 3 )
		expect( clone.all_of ).to include( location, tags, color )
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( location, color )
	end


	it "supports a fluent interface" do
		aspect = described_class.with_all_of( tags, location ).and_none_of( color )
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
		expect( aspect.none_of.size ).to eq( 1 )
		expect( aspect.none_of ).to include( color )
	end


	it "flattens Arrays passed to ::with_all_of" do
		aspect = described_class.with_all_of([ tags, location ])

		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_all_of" do
		aspect = described_class.new
		aspect = aspect.with_all_of([ tags, location ])

		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
	end


	it "flattens Arrays passed to ::with_one_of" do
		aspect = described_class.with_one_of([ tags, location ])

		expect( aspect.one_of.size ).to eq( 2 )
		expect( aspect.one_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_one_of" do
		aspect = described_class.new
		aspect = aspect.with_one_of([ tags, location ])

		expect( aspect.one_of.size ).to eq( 2 )
		expect( aspect.one_of ).to include( tags, location )
	end


	it "flattens Arrays passed to ::with_none_of" do
		aspect = described_class.with_none_of([ tags, location ])

		expect( aspect.none_of.size ).to eq( 2 )
		expect( aspect.none_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_none_of" do
		aspect = described_class.new
		aspect = aspect.with_none_of([ tags, location ])

		expect( aspect.none_of.size ).to eq( 2 )
		expect( aspect.none_of ).to include( tags, location )
	end


	it "can be inverted"


	describe "entity-matching" do

		let( :all_entities ) {[ entity1, entity2, entity3, entity4, entity5 ]}


		it "can find the matching subset of values given a Hash keyed by Components" do
			entities = all_entities()

			aspect = described_class.with_all_of( color, location ).and_none_of( tags )
			result = aspect.matching_entities( world.entities_by_component )

			expect( result ).to contain_exactly( entity2.id )
		end


		it "always matches an individual entity if it's empty" do
			aspect = described_class.new

			expect( aspect ).to match( entity1 )
			expect( aspect ).to match( entity2 )
			expect( aspect ).to match( entity3 )
			expect( aspect ).to match( entity4 )
			expect( aspect ).to match( entity5 )
		end


		it "matches an individual entity if its components meet the criteria" do
			aspect = described_class.with_all_of( color, location ).and_none_of( tags )

			expect( aspect ).to_not match( entity1 )
			expect( aspect ).to match( entity2 )
			expect( aspect ).to_not match( entity3 )
			expect( aspect ).to_not match( entity4 )
			expect( aspect ).to_not match( entity5 )

			aspect = described_class.with_one_of( tags, color )

			expect( aspect ).to_not match( entity1 )
			expect( aspect ).to match( entity2 )
			expect( aspect ).to match( entity3 )
			expect( aspect ).to match( entity4 )
			expect( aspect ).to match( entity5 )
		end


		it "matches a component hash if it meets the criteria" do
			aspect = described_class.with_all_of( color, location ).and_none_of( tags )

			expect( aspect ).to_not match( entity1.components )
			expect( aspect ).to match( entity2.components )
			expect( aspect ).to_not match( entity3.components )
			expect( aspect ).to_not match( entity4.components )
			expect( aspect ).to_not match( entity5.components )
		end

	end


	describe "and Archetypes" do

		let( :testing_archetype ) do
			arch = Module.new do
				def self::name; "Testing"; end
			end
			arch.extend( Chione::Archetype )
			arch.add( location )
			arch.add( color )
			arch
		end


		it "can be created to match a particular Archetype" do
			instance = described_class.for_archetype( testing_archetype )
			expect( instance ).to be_a( described_class )
			expect( instance.all_of ).to contain_exactly( location, color )
		end


		it "reuses an instance used to create an archetype" do
			instance = described_class.with_all_of([ color ]).with_one_of([ tags, location ])
			arch = Chione::Archetype.from_aspect( instance )
			expect( described_class.for_archetype(arch) ).to equal( instance )
		end

	end

end

