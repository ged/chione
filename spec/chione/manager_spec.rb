#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/manager'
require 'chione/world'


describe Chione::Manager do

	let( :world ) { Chione::World.new }


	describe "concrete derivatives" do

		let( :manager_class ) do
			Class.new( described_class )
		end

		let( :manager ) { manager_class.new(world) }


		it "are required to implement #start" do
			expect {
				manager.start
			}.to raise_error( NotImplementedError, /does not implement/i )
		end


		it "are required to implement #stop" do
			expect {
				manager.stop
			}.to raise_error( NotImplementedError, /does not implement/i )
		end

	end

end

