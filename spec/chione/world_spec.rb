#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/world'

require 'chione/aspect'
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


	describe "publish/subscribe" do

		it "allows subscription to events" do
			received = []
			world.subscribe( 'test/subscription' ) {|*args| received << args }
			expect {
				world.publish( 'test/subscription' )
			}.to change { received.length }.by( 1 )

			expect( received ).to eq([ ['test/subscription', []] ])
		end


		it "allows unsubscription from events via the returned callback" do
			received = []
			callback = world.subscribe( 'test/subscription' ) {|*args| received << args }
			world.unsubscribe( callback )

			expect {
				world.publish( 'test/subscription' )
			}.to_not change { received.length }
		end


		describe "with glob-style wildcard patterns" do

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

		it "can create entities" do
			expect( world.create_entity ).to be_a( Chione::Entity )
		end


		it "broadcasts an `entity/created` event when it creates an Entity" do
			event_payload = nil

			world.subscribe( 'entity/created' ) {|*payload| event_payload = payload }
			entity = world.create_entity

			expect( event_payload ).to eq([ 'entity/created', [entity] ])
		end

	end


	describe "components" do

		let( :entity ) { world.create_entity }


		it "can look up sets of entities which match Aspects" do
			entity1 = world.create_entity
			entity1.add_component( location_component.new )

			entity2 = world.create_entity
			entity2.add_component( location_component.new )
			entity2.add_component( tags_component.new )

			entity3 = world.create_entity
			entity3.add_component( tags_component.new )

			location_aspect = Chione::Aspect.with_one_of( location_component )
			entities_with_location = world.entities_with( location_aspect )
			expect( entities_with_location ).to include( entity1, entity2 )
			expect( entities_with_location ).to_not include( entity3 )

			tags_aspect = Chione::Aspect.with_one_of( tags_component )
			entities_with_tags = world.entities_with( tags_aspect )
			expect( entities_with_tags ).to include( entity2, entity3 )
			expect( entities_with_tags ).to_not include( entity1 )

			tagged_located_aspect = Chione::Aspect.with_all_of( location_component, tags_component )
			entities_with_both = world.entities_with( tagged_located_aspect )
			expect( entities_with_both ).to include( entity2 )
			expect( entities_with_both ).to_not include( entity1, entity3 )

			colored_aspect = Chione::Aspect.with_one_of( color_component )
			entities_with_color = world.entities_with( colored_aspect )
			expect( entities_with_color ).to be_empty
		end

	end


	describe "systems" do

		it "can have Systems added to it" do
			system = world.add_system( test_system )
			expect( world.systems ).to include( test_system )
			expect( world.systems[test_system] ).to be( system )
		end


		it "can register Systems constructed with custom arguments" do
			system = world.add_system( test_system, 1, 2 )
			expect( system.args ).to eq([ 1, 2 ])
		end


		it "broadcasts a `system/added` event when a System is added" do
			event_payload = nil
			world.subscribe( 'system/added' ) {|*payload| event_payload = payload }

			sys = world.add_system( test_system )

			expect( event_payload ).to eq([ 'system/added', [test_system] ])
		end


		it "starts its systems when it starts up" do
			system = world.add_system( test_system )
			world.start
			sleep 0.1 until world.running?
			world.stop
			expect( system.started ).to be_truthy
		end

	end


	describe "managers" do

		it "can register Managers" do
			manager = world.add_manager( test_manager )
			expect( world.managers ).to include( test_manager )
			expect( world.managers[test_manager] ).to be( manager )
		end


		it "can register Managers constructed with custom arguments" do
			manager = world.add_manager( test_manager, 1, 2 )
			expect( manager.args ).to eq([ 1, 2 ])
		end


		it "broadcasts a `manager/added` event when a Manager is added" do
			event_payload = nil
			world.subscribe( 'manager/added' ) {|*payload| event_payload = payload }

			manager = world.add_manager( test_manager )

			expect( event_payload ).to eq([ 'manager/added', [test_manager] ])
		end


		it "starts its managers when it starts up" do
			manager = world.add_manager( test_manager )
			world.start
			sleep 0.1 until world.running?
			world.stop
			expect( manager.started ).to be_truthy
		end

	end

end

