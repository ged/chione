#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/iterating_system'
require 'chione/fixtures'


RSpec.describe Chione::IteratingSystem do

	before( :all ) do
		Chione::Fixtures.load( :entities )
		@component_classes = Chione::Component.derivatives.dup
	end
	before( :each ) do
		Chione::Component.derivatives.clear
	end
	after( :all ) do
		Chione::Component.derivatives.replace( @component_classes )
	end


	let( :subclass ) { Class.new(described_class) }
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


	describe "instances" do

		let( :instance ) { subclass.new(world) }


		it "requires an override for the #process method" do
			expect( instance ).to respond_to( :process )
			expect {
				instance.process( :default, 'entity-id', {} )
			}.to raise_error( NotImplementedError, /#process/i )
		end


		describe "with a process method" do

			let( :entity ) { Chione::Fixtures.entity(world) }


			let( :subclass ) do
				cls = super()
				cls.class_exec(location_component, bounding_box_component) do |location, bbox|
					aspect :default, all_of: [location, bbox]
					aspect :emphemeral, all_of: [location], none_of: bbox

					def initialize( * )
						super
						@calls = []
					end

					attr_reader :calls

					def process( aspect_name, entity_id, components )
						@calls << [ aspect_name, entity_id, components ]
					end
				end

				cls
			end


			it "gets called for each entity which matches an aspect on each tick" do
				entities_with_location = entity.with_components( location_component ).
					generator.take( 5 ) # :ephemeral
				entities_with_bb = entity.with_components( bounding_box_component ).
					generator.take( 5 ) # -
				entities_with_both = entity.
					with_components( location_component, bounding_box_component ).
					generator.take( 5 ) # :default

				sys = world.add_system( subclass )
				sys.start

				world.publish( 'timing', 0.5, 1 )
				world.publish_deferred_events

				both_components = a_hash_including( location_component, bounding_box_component )
				only_location_component = a_hash_including( location_component )

				expect( sys.calls.length ).to eq( 10 )
				expect( sys.calls ).to contain_exactly(
					[:default, entities_with_both[0].id, both_components ],
					[:default, entities_with_both[1].id, both_components ],
					[:default, entities_with_both[2].id, both_components ],
					[:default, entities_with_both[3].id, both_components ],
					[:default, entities_with_both[4].id, both_components ],
					[:emphemeral, entities_with_location[0].id, only_location_component ],
					[:emphemeral, entities_with_location[1].id, only_location_component ],
					[:emphemeral, entities_with_location[2].id, only_location_component ],
					[:emphemeral, entities_with_location[3].id, only_location_component ],
					[:emphemeral, entities_with_location[4].id, only_location_component ]
				)
			end

		end

	end


end

