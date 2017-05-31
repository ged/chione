#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/entity'
require 'chione/component'


describe Chione::Entity do

	before( :all ) do
		@component_classes = Chione::Component.derivatives.dup
	end
	before( :each ) do
		Chione::Component.derivatives.clear
	end
	after( :all ) do
		Chione::Component.derivatives.replace( @component_classes )
	end


	let( :world ) { Chione::World.new }

	let( :location_component ) do
		klass = Class.new( Chione::Component ) do
			def self::name; "Location"; end
			field :x, default: 0
			field :y, default: 0
		end
		Chione::Component.derivatives['location'] = klass
		klass
	end

	let( :tags_component ) do
		klass = Class.new( Chione::Component ) do
			def self::name; "Tags"; end
			field :tags, default: []
		end
		Chione::Component.derivatives['tags'] = klass
		klass
	end

	let( :bounding_box_component ) do
		klass = Class.new( Chione::Component ) do
			def self::name; "BoundingBox"; end
			field :width, default: 1
			field :height, default: 1
			field :depth, default: 1
		end
		Chione::Component.derivatives['bounding_box'] = klass
		klass
	end


	it "knows what world it was created for" do
		expect( Chione::Entity.new(world).world ).to be( world )
	end


	it "uses the ID it's given in creation" do
		entity = Chione::Entity.new( world, 'some-other-id' )
		expect( entity.id ).to eq( 'some-other-id' )
	end


	it "generates an ID for itself if it isn't given one" do
		entity = Chione::Entity.new( world )
		expect( entity.id ).to be_a( String )
		expect( entity.id.length ).to be >= 8

		expect( Chione::Entity.new(world).id ).to_not eq( entity.id )
	end


	describe "concrete instance" do

		let( :entity ) { Chione::Entity.new(world) }


		it "can have components added to it" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect( entity ).to have_component( location_component )
			expect( entity ).to have_component( tags_component )
		end


		it "can have components added to it by name" do
			location_component()
			tags_component()

			entity.add_component( :location )
			entity.add_component( :tags )

			expect( entity ).to have_component( location_component )
			expect( entity ).to have_component( tags_component )
		end


		it "lets components be fetched from it" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect(
				entity.find_component( location_component )
			).to eq( entity.components[location_component] )
		end


		it "supports backward-compatible component-fetcher method" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect(
				entity.get_component( location_component )
			).to eq( entity.components[location_component] )
		end


		it "lets one of a list of components be fetched from it" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect(
				entity.find_component( bounding_box_component, location_component )
			).to eq( entity.components[location_component] )
		end


		it "raises a KeyError if it doesn't have a fetched component" do
			entity.add_component( tags_component )

			expect {
				entity.find_component( location_component )
			}.to raise_error( KeyError, /#{entity.id} doesn't have/i )
		end


		it "raises a KeyError if it doesn't have any of several fetched components" do
			entity.add_component( tags_component )

			expect {
				entity.find_component( location_component, bounding_box_component )
			}.to raise_error( KeyError, /#{entity.id} doesn't have any of/i )
		end

	end

end

