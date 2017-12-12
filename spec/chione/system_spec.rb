#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/system'
require 'chione/fixtures'


describe Chione::System do

	before( :all ) do
		Chione::Fixtures.load( :entities )
	end


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

	let( :volition_component ) do
		Class.new( Chione::Component ) do
			field :verbs, default: []
		end
	end


	describe "subclass" do

		let( :subclass ) do
			Class.new( described_class ) do
				def initialize( * )
					super
					@calls = []
				end
				attr_reader :calls

				def inserted( *args )
					self.calls << [ __method__, args ]
					super
				end
				def removed( *args )
					self.calls << [ __method__, args ]
					super
				end
			end
		end
		let( :world ) { Chione::World.new }


		describe "aspects" do

			it "has a default Aspect which matches all entities" do
				expect( subclass.aspects ).to be_empty
				expect( subclass.aspects[:default] ).to be_empty
			end


			it "can declare components for its default aspect" do
				subclass.aspect :default,
					all_of: volition_component,
					one_of: [ tags_component, location_component ]

				expect( subclass.aspects.keys ).to contain_exactly( :default )
				expect( subclass.aspects[:default].all_of ).to include( volition_component )
				expect( subclass.aspects[:default].one_of ).
					to include( tags_component, location_component )
			end


			it "can declare a named aspect" do
				subclass.aspect( :with_location, all_of: location_component )

				expect( subclass.aspects.keys ).to contain_exactly( :with_location )
				expect( subclass.aspects[:with_location].all_of ).
					to contain_exactly( location_component )
			end


			it "can declare a named aspect using simplified syntax" do
				subclass.aspect( :with_location, location_component )

				expect( subclass.aspects.keys ).to contain_exactly( :with_location )
				expect( subclass.aspects[:with_location].all_of ).
					to contain_exactly( location_component )
			end


			it "can declare more than one named aspect" do
				subclass.aspect( :with_location, all_of: location_component )
				subclass.aspect( :self_movable, all_of: [location_component, volition_component] )

				expect( subclass.aspects.keys ).to contain_exactly( :with_location, :self_movable )
				expect( subclass.aspects[:with_location].all_of ).to contain_exactly( location_component )
				expect( subclass.aspects[:self_movable].all_of ).
					to contain_exactly( location_component, volition_component )
			end


			it "keeps an explicitly-defined default aspect event if other named ones are added" do
				subclass.aspect( :default, all_of: location_component )
				subclass.aspect( :self_movable, all_of: [location_component, volition_component] )

				expect( subclass.aspects.keys ).to contain_exactly( :default, :self_movable )
				expect( subclass.aspects[:default].all_of ).to contain_exactly( location_component )
				expect( subclass.aspects[:self_movable].all_of ).
					to contain_exactly( location_component, volition_component )
			end


			it "is notified when adding a component causes an entity to start matching one of its aspects" do
				subclass.aspect( :with_location, all_of: location_component )
				subclass.aspect( :self_movable, all_of: [location_component, volition_component] )

				entity = world.create_entity

				sys = world.add_system( subclass )
				sys.start

				world.add_component_to( entity, location_component )
				world.publish_deferred_events

				expect( sys.calls.length ).to eq( 1 )
				expect( sys.calls ).to include([
						:inserted, [
							:with_location,
							entity.id,
							{location_component => an_instance_of(location_component)}
						]
					])

				world.add_component_to( entity, volition_component )
				world.publish_deferred_events

				expect( sys.calls.length ).to eq( 2 )
				expect( sys.calls ).to include([
						:inserted, [
							:self_movable,
							entity.id,
							{
								location_component => an_instance_of(location_component),
								volition_component => an_instance_of(volition_component)
							}
						]
					])
			end


			it "is notified when removing a component causes an entity to no longer match one of its aspects" do
				subclass.aspect( :with_location, all_of: location_component )
				subclass.aspect( :self_movable, all_of: [location_component, volition_component] )

				entity = world.create_entity
				world.add_component_to( entity, location_component )
				world.add_component_to( entity, volition_component )
				world.publish_deferred_events

				sys = world.add_system( subclass )
				sys.start

				world.remove_component_from( entity, volition_component )
				world.publish_deferred_events

				expect( sys.calls.length ).to eq( 1 )
				expect( sys.calls ).to include([
						:removed, [
							:self_movable,
							entity.id,
							{location_component => an_instance_of(location_component)}
						]
					])

				world.remove_component_from( entity, location_component )
				world.publish_deferred_events

				expect( sys.calls.length ).to eq( 2 )
				expect( sys.calls ).to include([
						:removed, [
							:with_location,
							entity.id,
							{}
						]
					])
			end

		end


		describe "event handlers" do

			it "has no event handlers by default" do
				expect( subclass.event_handlers ).to be_empty
			end


			it "can register a handler method for an event" do
				subclass.on( 'entity/created' ) do |*|
					# no-op
				end

				expect( subclass.event_handlers ).
					to include( ['entity/created', 'on_entity_created_event'] )
				expect( subclass.instance_methods ).to include( :on_entity_created_event )
			end


			it "provides a convenience declaration for the timing event" do
				subclass.every_tick do |*|
					# no-op
				end

				expect( subclass.event_handlers ).
					to include( ['timing', 'on_timing_event'] )
				expect( subclass.instance_methods ).to include( :on_timing_event )
			end


			it "unwraps arguments to `every_tick` callbacks" do
				received_delta = received_tick = nil
				subclass.every_tick do |delta, tick|
					received_delta = delta
					received_tick = tick
				end

				instance = subclass.new( world )
				instance.on_timing_event( 'timing', [0.016666666666666666, 0] )

				expect( received_delta ).to be_within( 0.00001 ).of( 0.016666666666666666 )
				expect( received_tick ).to eq( 0 )
			end

		end


		describe "instance" do

			let( :subclass ) do
				subclass = Class.new( described_class )
				subclass.aspect( :default,
					all_of: volition_component,
					one_of: [tags_component, location_component] )
				subclass.aspect( :tagged, all_of: tags_component )
				subclass
			end

			let( :instance ) do
				subclass.new( world )
			end


			before( :each ) do
				@ent1 = world.create_entity
				@ent1.add_component( volition_component )
				@ent1.add_component( tags_component )

				@ent2 = world.create_entity
				@ent2.add_component( volition_component )
				@ent2.add_component( location_component )

				@ent3 = world.create_entity
				@ent3.add_component( volition_component )

				@ent4 = world.create_entity
				@ent4.add_component( location_component )
				@ent4.add_component( tags_component )
			end


			it "can enumerate the entities from the world that match its default aspect" do
				expect( instance.entities ).to be_a( Enumerator )
				expect( instance.entities ).to contain_exactly( @ent1.id, @ent2.id )
			end


			it "can enumerate the entities from the world that match one of its named aspects" do
				expect( instance.entities(:tagged) ).to be_a( Enumerator )
				expect( instance.entities(:tagged) ).to contain_exactly( @ent1.id, @ent4.id )
			end


		end

	end

end

