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
			Class.new(described_class) do
				def initialize( * )
					super
					@processed = false
				end
				attr_reader :processed

				def process_loop
					@processed = true
				end
			end
		end


		it "has a default Aspect which matches all entities" do
			expect( subclass.aspect ).to be_empty
		end


		it "can declare components for its aspect" do
			subclass.aspect one_of: tags_component

			expect( subclass.aspect ).to_not be_empty
			expect( subclass.aspect.one_of ).to include( tags_component )
		end


		it "is required to implement #process_loop" do
			expect {
				Class.new( described_class ).new( :world ).process_loop
			}.to raise_error( NotImplementedError, /implement required method/i )
		end


		it "runs a Thread in its #process_loop when started" do
			system = subclass.new( :world )
			system_thread = system.start
			expect( system_thread ).to be_a( Thread )
			system_thread.join( 2 )
			expect( system.processed ).to be_truthy
		end

	end

end

