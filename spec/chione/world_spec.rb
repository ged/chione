#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/world'

require 'chione/aspect'
require 'chione/archetype'
require 'chione/component'
require 'chione/entity'
require 'chione/manager'
require 'chione/system'


describe Chione::World do

	let( :world ) { described_class.new }

	let( :test_system ) do
		Class.new( Chione::System ) do
			def self::name; "TestSystem"; end
			def initialize( world, *args )
				super
				@args = args
				@started = false
				@stopped = false
			end
			attr_reader :args, :started, :stopped
			def start
				@started = true
			end
			def stop
				@stopped = true
			end
		end
	end
	let( :test_manager ) do
		Class.new( Chione::Manager ) do
			def self::name; "TestManager"; end
			def initialize( world, *args )
				super
				@args = args
			end
			attr_reader :args, :started, :stopped
			def start
				@started = true
			end
			def stop
				@stopped = true
			end
		end
	end

	let( :location_component ) do
		Class.new( Chione::Component ) do
			def self::name
				"Location"
			end
			field :x, default: 0
			field :y, default: 0
		end
	end

	let( :tags_component ) do
		Class.new( Chione::Component ) do
			def self::name
				"Tags"
			end
			field :tags, default: []
		end
	end

	let( :color_component ) do
		Class.new( Chione::Component ) do
			def self::name
				"Color"
			end
			field :hue, default: 0
			field :shade, default: 0
			field :value, default: 0
			field :opacity, default: 0
		end
	end

	let( :archetype ) do
		mod = Module.new
		mod.extend( Chione::Archetype )
		mod.add( location_component, x: 10, y: 8 )
		mod.add( tags_component, tags: [:foo, :bar] )
		mod
	end


	describe "configuration" do

		it "is done via the Configurability API" do
			new_stop_wait = Chione::World::CONFIG_DEFAULTS[:max_stop_wait] + 10
			config = Configurability.default_config
			config.gameworld = {
				max_stop_wait: new_stop_wait
			}

			config.install

			expect( described_class.max_stop_wait ).to eq( new_stop_wait )
		end

	end


	describe "publish/subscribe" do


		it "starts out with events deferred" do
			expect( world ).to be_deferring_events
		end


		it "allows subscription to events" do
			received = []
			world.subscribe( 'test/subscription' ) {|*args| received << args }
			expect {
				world.publish( 'test/subscription' )
				world.publish_deferred_events
			}.to change { received.length }.by( 1 )

			expect( received ).to eq([ ['test/subscription', []] ])
		end


		it "allows more than one subscription to the same event pattern" do
			received = []
			world.subscribe( 'test/subscription' ) {|*args| received << 1 }
			world.subscribe( 'test/subscription' ) {|*args| received << 2 }
			expect {
				world.publish( 'test/subscription' )
				world.publish_deferred_events
			}.to change { received.length }.by( 2 )

			expect( received ).to eq([ 1, 2 ])
		end


		it "removes subscriptions that raise errors" do
			callback = world.subscribe( 'test/subscription' ) {|*args| raise "oops" }
			expect {
				Loggability.with_level( :fatal ) do
					world.publish( 'test/subscription' )
					world.publish_deferred_events
				end
			}.to change { world.subscriptions['test/subscription'].length }.by( -1 )
			expect( world.subscriptions['test/subscriptions'] ).to_not include( callback )
		end


		it "allows unsubscription from events via the returned callback" do
			received = []
			callback = world.subscribe( 'test/subscription' ) {|*args| received << args }
			world.unsubscribe( callback )

			expect {
				world.publish( 'test/subscription' )
				world.publish_deferred_events
			}.to_not change { received.length }
		end


		describe "with glob-style wildcard patterns" do

			let( :world ) do
				instance = super()
				instance.defer_events = false
				instance
			end


			it "matches any one event segment with an asterisk" do
				received = []

				world.subscribe( 'test/*' ) {|*args| received << args }

				expect {
					world.publish( 'test/subscription', :stuff )
					world.publish( 'test/other', 18, 2 )
					world.publish( 'test/with/more', :chinchillas )
				}.to change { received.length }.by( 2 )

				expect( received ).to eq([
					['test/subscription', [:stuff]],
					['test/other', [18, 2]],
				])
			end

			it "matches any number of event segments with a double-asterisk" do
				received = []

				world.subscribe( 'test/**/*' ) {|*args| received << args }

				expect {
					world.publish( 'test/subscription', :stuff )
					world.publish( 'test/other', 22, 8 )
					world.publish( 'test/with/more' )
					world.publish( 'entity/something', 'leopards' )
				}.to change { received.length }.by( 3 )
			end

			it "matches alternatives with a curly-braced list" do
				received = []

				world.subscribe( 'test/{foo,bar}' ) {|*args| received << args }

				expect {
					world.publish( 'test/foo', :calliope )
					world.publish( 'test/bar', size: 8, length: 24.4 )
					world.publish( 'test/bar/more', {} )
					world.publish( 'test/more' )
				}.to change { received.length }.by( 2 )

				expect( received ).to eq([
					[ 'test/foo', [:calliope] ],
					[ 'test/bar', [{size: 8, length: 24.4}] ],
				])
			end

		end

	end


	describe "entities" do

		let( :world ) do
			instance = super()
			instance.defer_events = false
			instance
		end


		it "can create entities" do
			expect( world.create_entity ).to be_a( Chione::Entity )
		end


		it "knows whether or not it has a particular entity" do
			entity = world.create_entity
			expect( world ).to have_entity( entity )
		end


		it "knows whether or not it has an entity with a given ID" do
			entity = world.create_entity
			id = entity.id

			expect( world ).to have_entity( id )
		end


		it "can create entities using an Archetype" do
			entity = world.create_entity( archetype )

			expect( entity ).to be_a( Chione::Entity )
			expect( world.components_for(entity).keys ).
				to contain_exactly( *archetype.components.keys )
		end


		it "publishes an `entity/created` event when it creates an Entity" do
			event_payload = nil

			world.subscribe( 'entity/created' ) {|*payload| event_payload = payload }
			entity = world.create_entity

			expect( event_payload ).to eq([ 'entity/created', [entity.id] ])
		end


		it "can destroy entities" do
			entity = world.create_entity
			world.destroy_entity( entity )

			expect( world ).to_not have_entity( entity )
		end


		it "errors when trying to destroy an entity that was already destroyed" do
			entity = world.create_entity
			world.destroy_entity( entity )
			expect {
				world.destroy_entity( entity )
			}.to raise_error( /does not contain entity \S+/i )
		end


		it "publishes an `entity/destroyed` event when it destroys an Entity" do
			event_payload = nil

			world.subscribe( 'entity/destroyed' ) {|*payload| event_payload = payload }
			entity = world.create_entity
			world.destroy_entity( entity )
			world.publish_deferred_events

			expect( event_payload ).to eq([ 'entity/destroyed', [entity] ])
		end

	end


	describe "components" do

		it "can add a component for an entity" do
			entity = world.create_entity
			world.add_component_to( entity, location_component )
			expect( world ).to have_component_for( entity, location_component )
		end


		it "can remove a component from an entity" do
			entity = world.create_entity
			world.add_component_to( entity, location_component )
			world.remove_component_from( entity, location_component )
			expect( world ).to_not have_component_for( entity, location_component )
		end


		it "can test to see whether an entity has a component type" do
			entity = world.create_entity

			expect( world ).to_not have_component_for( entity, location_component )
			world.add_component_to( entity, location_component )
			expect( world ).to have_component_for( entity, location_component )
		end

	end


	describe "systems" do

		let( :world ) do
			instance = super()
			instance.defer_events = false
			instance
		end


		it "can have Systems added to it" do
			system = world.add_system( test_system )
			expect( world.systems ).to include( test_system )
			expect( world.systems[test_system] ).to be( system )
		end


		it "can have Systems removed from it" do
			world.add_system( test_system )
			result = world.remove_system( test_system )
			expect( world.systems ).to_not include( test_system )
			expect( result ).to be_a( test_system )
		end


		it "can register Systems constructed with custom arguments" do
			system = world.add_system( test_system, 1, 2 )
			expect( system.args ).to eq([ 1, 2 ])
		end


		it "broadcasts a `system/added` event when a System is added" do
			event_payload = nil
			world.defer_events = false
			world.subscribe( 'system/added' ) {|*payload| event_payload = payload }

			sys = world.add_system( test_system )

			expect( event_payload ).to eq([ 'system/added', [sys] ])
		end


		it "broadcasts a `system/removed` event when a System is removed" do
			event_payload = nil
			world.defer_events = false
			world.subscribe( 'system/removed' ) {|*payload| event_payload = payload }

			sys = world.add_system( test_system )
			world.remove_system( test_system )

			expect( event_payload ).to eq([ 'system/removed', [sys] ])
		end


		it "starts its systems when it starts up" do
			system = world.add_system( test_system )
			world.start
			sleep 0.1 until world.running?
			world.stop
			expect( system.started ).to be_truthy
		end


		it "starts a system as soon as it's added if it's already started" do
			world.start
			sleep 0.1 until world.running?
			system = world.add_system( test_system )
			world.stop
			expect( system.started ).to be_truthy
		end


		it "stops a system before it's removed if it was started" do
			system = world.add_system( test_system )
			world.start
			sleep 0.1 until world.running?
			world.remove_system( test_system )
			expect( system.stopped ).to be_truthy
			world.stop
		end

	end


	describe "aspects" do

		let( :entity1 ) do
			obj = world.create_entity
			obj.add_component( location_component.new )
			obj
		end
		let( :entity2 ) do
			obj = world.create_entity
			obj.add_component( location_component.new )
			obj.add_component( tags_component.new )
			obj
		end
		let( :entity3 ) do
			obj = world.create_entity
			obj.add_component( tags_component.new )
			obj
		end

		let( :location_aspect ) { Chione::Aspect.with_one_of(location_component) }
		let( :tags_aspect ) { Chione::Aspect.with_one_of(tags_component) }
		let( :colored_aspect ) { Chione::Aspect.with_one_of(color_component) }
		let( :tagged_located_aspect ) do
			Chione::Aspect.with_all_of( location_component, tags_component )
		end


		it "can look up sets of entities which match Aspects" do
			entities_with_location = world.entities_with( location_aspect )
			expect( entities_with_location ).to contain_exactly( entity1.id, entity2.id )

			entities_with_tags = world.entities_with( tags_aspect )
			expect( entities_with_tags ).to contain_exactly( entity2.id, entity3.id )

			entities_with_both = world.entities_with( tagged_located_aspect )
			expect( entities_with_both ).to contain_exactly( entity2.id )

			entities_with_color = world.entities_with( colored_aspect )
			expect( entities_with_color ).to be_empty
		end

	end


	describe "managers" do

		let( :world ) do
			instance = super()
			instance.defer_events = false
			instance
		end


		it "can have Managers added to it" do
			manager = world.add_manager( test_manager )
			expect( world.managers ).to include( test_manager )
			expect( world.managers[test_manager] ).to be( manager )
		end


		it "can have Managers removed from it" do
			world.add_manager( test_manager )
			world.remove_manager( test_manager )
			expect( world.managers ).to_not include( test_manager )
		end


		it "can register Managers constructed with custom arguments" do
			manager = world.add_manager( test_manager, 1, 2 )
			expect( manager.args ).to eq([ 1, 2 ])
		end


		it "broadcasts a `manager/added` event when a Manager is added" do
			event_payload = nil
			world.defer_events = false
			world.subscribe( 'manager/added' ) {|*payload| event_payload = payload }

			manager = world.add_manager( test_manager )

			expect( event_payload ).to eq([ 'manager/added', [manager] ])
		end


		it "broadcasts a `manager/removed` event when a Manager is removed" do
			event_payload = nil
			world.defer_events = false
			world.subscribe( 'manager/removed' ) {|*payload| event_payload = payload }

			world.add_manager( test_manager )
			manager = world.remove_manager( test_manager )

			expect( event_payload ).to eq([ 'manager/removed', [manager] ])
		end


		it "starts its managers when it starts up" do
			manager = world.add_manager( test_manager )
			world.start
			sleep 0.1 until world.running?
			world.stop
			expect( manager.started ).to be_truthy
		end


		it "starts a manager as soon as it's added if it's already been started" do
			world.start
			sleep 0.1 until world.running?
			manager = world.add_manager( test_manager )
			world.stop
			expect( manager.started ).to be_truthy
		end


		it "stops a manager when it's removed if it was started" do
			world.add_manager( test_manager )
			world.start
			sleep 0.1 until world.running?
			manager = world.remove_manager( test_manager )
			expect( manager.stopped ).to be_truthy
			world.stop
		end

	end

end

