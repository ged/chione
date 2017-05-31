#!/usr/bin/env rspec -cfd -b

require_relative 'spec_helper'

require 'chione'

describe Chione do

	after( :all ) do
		Chione::Component.derivatives.clear
	end


	it "can coerce Chione::Component classes into instances" do
		component_class = Class.new( Chione::Component )
		expect( Chione::Component(component_class) ).to be_instance_of( component_class )
	end


	it "can coerce Chione::Component class names into instances" do
		component_class = Class.new( Chione::Component ) do
			def self::name; "Thermidore"; end
		end
		Chione::Component.derivatives[ 'thermidore' ] = component_class

		expect( Chione::Component(:thermidore) ).to be_instance_of( component_class )
	end


	it "returns coerced Chione::Component unchanged" do
		component_class = Class.new( Chione::Component )
		instance = component_class.new

		expect( Chione::Component(instance) ).to equal( instance )
	end

end

# vim: set nosta noet ts=4 sw=4:

