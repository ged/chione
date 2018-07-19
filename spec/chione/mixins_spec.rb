#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'chione/mixins'


describe Chione, "mixins" do

	describe Chione::MethodUtilities, 'used to extend a class' do

		let!( :extended_class ) do
			klass = Class.new
			klass.extend( Chione::MethodUtilities )
			klass
		end

		it "can declare a class-level attribute reader" do
			extended_class.singleton_attr_reader :foo
			expect( extended_class ).to respond_to( :foo )
			expect( extended_class ).to_not respond_to( :foo= )
			expect( extended_class ).to_not respond_to( :foo? )
		end

		it "can declare a class-level attribute writer" do
			extended_class.singleton_attr_writer :foo
			expect( extended_class ).to_not respond_to( :foo )
			expect( extended_class ).to respond_to( :foo= )
			expect( extended_class ).to_not respond_to( :foo? )
		end

		it "can declare a class-level attribute reader and writer" do
			extended_class.singleton_attr_accessor :foo
			expect( extended_class ).to respond_to( :foo )
			expect( extended_class ).to respond_to( :foo= )
			expect( extended_class ).to_not respond_to( :foo? )
		end

		it "can declare a class-level alias" do
			def extended_class.foo
				return "foo"
			end
			extended_class.singleton_method_alias( :bar, :foo )

			expect( extended_class.bar ).to eq( 'foo' )
		end

		it "can declare an instance attribute predicate method" do
			extended_class.attr_predicate :foo
			instance = extended_class.new

			expect( instance ).to_not respond_to( :foo )
			expect( instance ).to_not respond_to( :foo= )
			expect( instance ).to respond_to( :foo? )

			expect( instance.foo? ).to be_falsey

			instance.instance_variable_set( :@foo, 1 )
			expect( instance.foo? ).to be_truthy
		end

		it "can declare an instance attribute predicate and writer" do
			extended_class.attr_predicate_accessor :foo
			instance = extended_class.new

			expect( instance ).to_not respond_to( :foo )
			expect( instance ).to respond_to( :foo= )
			expect( instance ).to respond_to( :foo? )

			expect( instance.foo? ).to be_falsey

			instance.foo = 1
			expect( instance.foo? ).to be_truthy
		end

		it "can declare a class-level attribute predicate and writer" do
			extended_class.singleton_predicate_accessor :foo
			expect( extended_class ).to_not respond_to( :foo )
			expect( extended_class ).to respond_to( :foo= )
			expect( extended_class ).to respond_to( :foo? )
		end

		it "can declare a class-level predicate method" do
			extended_class.singleton_predicate_reader :foo
			expect( extended_class ).to_not respond_to( :foo )
			expect( extended_class ).to_not respond_to( :foo= )
			expect( extended_class ).to respond_to( :foo? )
		end

	end


	describe Chione::DataUtilities do

		it "doesn't try to dup immediate objects" do
			expect( Chione::DataUtilities.deep_copy( nil ) ).to be( nil )
			expect( Chione::DataUtilities.deep_copy( 112 ) ).to be( 112 )
			expect( Chione::DataUtilities.deep_copy( true ) ).to be( true )
			expect( Chione::DataUtilities.deep_copy( false ) ).to be( false )
			expect( Chione::DataUtilities.deep_copy( :a_symbol ) ).to be( :a_symbol )
		end

		it "doesn't try to dup modules/classes" do
			klass = Class.new
			expect( Chione::DataUtilities.deep_copy( klass ) ).to be( klass )
		end

		it "doesn't try to dup IOs" do
			data = [ $stdin ]
			expect( Chione::DataUtilities.deep_copy( data[0] ) ).to be( $stdin )
		end

		it "doesn't try to dup Tempfiles" do
			data = Tempfile.new( 'strelka_deepcopy.XXXXX' )
			expect( Chione::DataUtilities.deep_copy( data ) ).to be( data )
		end

		it "makes distinct copies of arrays and their members" do
			original = [ 'foom', Set.new([ 1,2 ]), :a_symbol ]

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to eq( original )
			expect( copy ).to_not be( original )
			expect( copy[0] ).to eq( original[0] )
			expect( copy[0] ).to_not be( original[0] )
			expect( copy[1] ).to eq( original[1] )
			expect( copy[1] ).to_not be( original[1] )
			expect( copy[2] ).to eq( original[2] )
			expect( copy[2] ).to be( original[2] ) # Immediate
		end

		it "makes recursive copies of deeply-nested Arrays" do
			original = [ 1, [ 2, 3, [4], 5], 6, [7, [8, 9], 0] ]

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to eq( original )
			expect( copy ).to_not be( original )
			expect( copy[1] ).to_not be( original[1] )
			expect( copy[1][2] ).to_not be( original[1][2] )
			expect( copy[3] ).to_not be( original[3] )
			expect( copy[3][1] ).to_not be( original[3][1] )
		end

		it "makes distinct copies of Hashes and their members" do
			original = {
				:a => 1,
				'b' => 2,
				3 => 'c',
			}

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to eq( original )
			expect( copy ).to_not be( original )
			expect( copy[:a] ).to eq( 1 )
			expect( copy.key( 2 ) ).to eq( 'b' )
			expect( copy.key( 2 ) ).to_not be( original.key(2) )
			expect( copy[3] ).to eq( 'c' )
			expect( copy[3] ).to_not be( original[3] )
		end

		it "makes distinct copies of deeply-nested Hashes" do
			original = {
				:a => {
					:b => {
						:c => 'd',
						:e => 'f',
					},
					:g => 'h',
				},
				:i => 'j',
			}

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to eq( original )
			expect( copy[:a][:b][:c] ).to eq( 'd' )
			expect( copy[:a][:b][:c] ).to_not be( original[:a][:b][:c] )
			expect( copy[:a][:b][:e] ).to eq( 'f' )
			expect( copy[:a][:b][:e] ).to_not be( original[:a][:b][:e] )
			expect( copy[:a][:g] ).to eq( 'h' )
			expect( copy[:a][:g] ).to_not be( original[:a][:g] )
			expect( copy[:i] ).to eq( 'j' )
			expect( copy[:i] ).to_not be( original[:i] )
		end

		it "copies the default proc of copied Hashes" do
			original = Hash.new {|h,k| h[ k ] = Set.new }

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy.default_proc ).to eq( original.default_proc )
		end

		it "preserves taintedness of copied objects" do
			original = Object.new
			original.taint

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to_not be( original )
			expect( copy ).to be_tainted()
		end

		it "preserves frozen-ness of copied objects" do
			original = Object.new
			original.freeze

			copy = Chione::DataUtilities.deep_copy( original )

			expect( copy ).to_not be( original )
			expect( copy ).to be_frozen()
		end

	end

end

