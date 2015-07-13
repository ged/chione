#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/entity'
require 'chione/component'


describe Chione::Entity do

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
			entity.add_component( location_component.new )
			entity.add_component( tags_component.new )

			expect( entity ).to have_component( location_component )
			expect( entity ).to have_component( tags_component )
		end


		it "lets components be fetched from it" do
			entity.add_component( location_component.new )
			entity.add_component( tags_component.new )

			expect(
				entity.get_component( location_component )
			).to eq( entity.components[location_component] )
		end


		it "raises a KeyError if a component that it doesn't have is fetched" do
			entity.add_component( tags_component.new )

			expect {
				entity.get_component( location_component )
			}.to raise_error( KeyError, /#{entity.id} doesn't have/i )
		end
	end

end

