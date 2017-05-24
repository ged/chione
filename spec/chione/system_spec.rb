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


	describe "a subclass" do

		let( :subclass ) do
			Class.new(described_class)
		end


		it "has a default Aspect which matches all entities" do
			expect( subclass.aspect ).to be_empty
		end


		it "can declare components for its aspect" do
			subclass.aspect one_of: tags_component

			expect( subclass.aspect ).to_not be_empty
			expect( subclass.aspect.one_of ).to include( tags_component )
		end


	end

end

