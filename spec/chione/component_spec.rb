#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/component'


describe Chione::Component do

	describe "concrete subclasses" do

		let( :component_subclass ) do
			Class.new( described_class )
		end


		it "can declare fields" do
			component_subclass.field( :x )
			component_subclass.field( :y )

			instance = component_subclass.new
			expect( instance ).to respond_to( :x )
			expect( instance ).to respond_to( :y )

			expect( instance.x ).to be_nil
			expect( instance.y ).to be_nil
		end


		it "can declare fields with default values" do
			component_subclass.field( :x, default: 0 )
			component_subclass.field( :y, default: 18 )

			instance = component_subclass.new
			expect( instance.x ).to eq( 0 )
			expect( instance.y ).to eq( 18 )
		end


		it "uses a dup of the default if it's not an immediate object" do
			component_subclass.field( :things, default: [] )

			instance1 = component_subclass.new
			instance2 = component_subclass.new

			instance1.things << "a thing"

			expect( instance2.things ).to be_empty
		end


		it "calls a callable default if it responds to #call" do
			component_subclass.field( :oid, default: ->(obj) { obj.object_id } )

			instance1 = component_subclass.new
			instance2 = component_subclass.new( oid: 121212 )

			expect( instance1.oid ).to eq( instance1.object_id )
			expect( instance2.oid ).to eq( 121212 )
		end

	end

end

