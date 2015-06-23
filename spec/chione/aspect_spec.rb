#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/aspect'
require 'chione/component'


describe Chione::Aspect do

	let( :location ) do
		Class.new( Chione::Component ) do
			field :x, default: 0
			field :y, default: 0
		end
	end

	let( :tags ) do
		Class.new( Chione::Component ) do
			field :tags, default: []
		end
	end

	let( :color ) do
		Class.new( Chione::Component ) do
			field :hue, default: 0
			field :shade, default: 0
			field :value, default: 0
			field :opacity, default: 0
		end
	end


	it "doesn't have any default criteria" do
		aspect = described_class.new
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of ).to be_empty
		expect( aspect.none_of ).to be_empty
		expect( aspect ).to be_empty
	end


	it "can be created with default criteria" do
		aspect = described_class.with_all_of( tags, location )
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
		expect( aspect.none_of ).to be_empty
	end


	it "can make a clone of itself with additional one_of criteria" do
		aspect = described_class.new
		clone = aspect.with_one_of( location, tags )
		expect( clone ).to_not be( aspect )
		expect( clone.one_of ).to include( location, tags )
		expect( aspect.one_of ).to be_empty
	end


	it "can make a clone of itself with additional none_of criteria" do
		aspect = described_class.with_none_of( location )
		clone = aspect.with_none_of( tags )
		expect( clone ).to_not be( aspect )
		expect( clone.none_of ).to include( location, tags )
		expect( aspect.none_of.size ).to eq( 1 )
		expect( aspect.none_of ).to include( location )
	end


	it "can make a clone of itself with additional all_of criteria" do
		aspect = described_class.with_all_of( color, location )
		clone = aspect.with_all_of( tags )
		expect( clone ).to_not be( aspect )
		expect( clone.all_of.size ).to eq( 3 )
		expect( clone.all_of ).to include( location, tags, color )
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( location, color )
	end


	it "supports a fluent interface" do
		aspect = described_class.with_all_of( tags, location ).and_none_of( color )
		expect( aspect.one_of ).to be_empty
		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
		expect( aspect.none_of.size ).to eq( 1 )
		expect( aspect.none_of ).to include( color )
	end


	it "flattens Arrays passed to ::with_all_of" do
		aspect = described_class.with_all_of([ tags, location ])

		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_all_of" do
		aspect = described_class.new
		aspect = aspect.with_all_of([ tags, location ])

		expect( aspect.all_of.size ).to eq( 2 )
		expect( aspect.all_of ).to include( tags, location )
	end


	it "flattens Arrays passed to ::with_one_of" do
		aspect = described_class.with_one_of([ tags, location ])

		expect( aspect.one_of.size ).to eq( 2 )
		expect( aspect.one_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_one_of" do
		aspect = described_class.new
		aspect = aspect.with_one_of([ tags, location ])

		expect( aspect.one_of.size ).to eq( 2 )
		expect( aspect.one_of ).to include( tags, location )
	end


	it "flattens Arrays passed to ::with_none_of" do
		aspect = described_class.with_none_of([ tags, location ])

		expect( aspect.none_of.size ).to eq( 2 )
		expect( aspect.none_of ).to include( tags, location )
	end


	it "flattens Arrays passed to #with_none_of" do
		aspect = described_class.new
		aspect = aspect.with_none_of([ tags, location ])

		expect( aspect.none_of.size ).to eq( 2 )
		expect( aspect.none_of ).to include( tags, location )
	end

end

