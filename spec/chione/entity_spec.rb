#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/entity'
require 'chione/component'


RSpec.describe Chione::Entity do

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


		it "can have components with init arguments added to it" do
			entity.add_component( location_component, x: 18, y: 51 )
			entity.add_component( tags_component, tags: ['trace', 'volatile'] )

			expect( entity.get_component(location_component).x ).to eq( 18 )
			expect( entity.get_component(location_component).y ).to eq( 51 )
			expect( entity.get_component(tags_component).tags ).to contain_exactly('trace', 'volatile')
		end


		it "lets components be fetched for it" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect(
				entity.get_component( location_component )
			).to be_an_instance_of( location_component )
		end


		it "can have components removed from it" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			entity.remove_component( tags_component )

			expect( entity ).to have_component( location_component )
			expect( entity ).to_not have_component( tags_component )
		end


		it "returns nil when fetching a component the entity doesn't have" do
			entity.add_component( location_component )
			entity.add_component( tags_component )

			expect(
				entity.get_component( bounding_box_component )
			).to be_nil
		end


		it "is equal to another instance if they have the same ID" do
			other_entity = described_class.new( entity.world, entity.id )

			expect( entity ).to eq( other_entity )
		end


		it "is not equal to an instance of another class" do
			other_object = Chione::Aspect.new

			expect( entity ).to_not eq( other_object )
		end

	end

end

