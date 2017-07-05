#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/system'


describe Chione::System do

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
			Class.new(described_class)
		end
		let( :world ) { Chione::World.new }


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


		describe "instance" do

			let( :subclass ) do
				subclass = super()
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

