# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'pluggability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'


# The Component (data) class
class Chione::Component
	extend Loggability,
	    Pluggability,
		Chione::MethodUtilities

	include Chione::Inspection


	# Loggability API -- log to the 'chione' logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/component' directory
	plugin_prefixes 'chione/component'

	##
	# The Hash of fields implemented by the component
	singleton_attr_accessor :fields


	### Inheritance callback -- add some default instance variable values to
	### subclasses.
	def self::inherited( subclass )
		super

		subclass.fields ||= {}
	end


	### Declare a field for the component named +name+, with a default value of
	### +default+. If the optional +process_block+ is provided, it will be called
	### with the new value being assigned to the field before it is set, and the
	### return value of it will be used instead.
	def self::field( name, **options, &process_block )
		options[ :processor ] = process_block
		self.fields ||= {}
		self.fields[ name ] = options

		# Add some class method
		self.define_singleton_method( "processor_for_#{name}" ) do
			return self.fields.dig( name, :processor )
		end
		self.define_singleton_method( "default_for_#{name}" ) do
			default = self.fields.dig( name, :default )
			return default.call( self ) if default.respond_to?( :call )
			return Chione::DataUtilities.deep_copy( default )
		end
		self.define_singleton_method( "options_for_#{name}" ) do
			return self.fields[ name ]
		end

		# Add instance methods as a mixin so they can be overridden and super()ed to
		mixin = self.make_field_mixin( name )
		self.include( mixin )

	end


	### Make a mixin module with methods for the field with the specified +name+.
	def self::make_field_mixin( name )
		mixin = Module.new

		mixin.attr_reader( name )
		mixin.define_method( "process_#{name}" ) do |value|
			processor = self.class.send( "processor_for_#{name}" ) or return value
			return processor.call( value )
		end
		mixin.define_method( "#{name}=" ) do |new_val|
			new_val = self.send( "process_#{name}", new_val )
			self.instance_variable_set( "@#{name}", new_val )
		end

		return mixin
	end


	### Create a new component with the specified +values+.
	def initialize( entity_id=nil, values={} )
		if entity_id.is_a?( Hash )
			values = entity_id
			entity_id = nil
		end

		@entity_id = entity_id

		if self.class.fields
			self.class.fields.each_key do |name|
				val = values[ name ] || self.class.send( "default_for_#{name}" )
				self.public_send( "#{name}=", val )
			end
		end
	end


	######
	public
	######

	##
	# The ID of the entity the component belongs to
	attr_accessor :entity_id


	#########
	protected
	#########

	### Return the detailed part of the Component's #inspect output.
	def inspect_details
		return "{%s} %s" % [
			self.entity_id || "(unassigned)",
			self.fields_description
		]
	end


	### Return a description of the fields this component has.
	def fields_description
		return self.class.fields.keys.collect do |name|
			val = self.instance_variable_get( "@#{name}" )
			"%s: %s" % [
				name,
				truncate_string( val.inspect, 20 )
			]
		end.join( ' ' )
	end



	#######
	private
	#######

	### Return a slice of the specified +string+ truncated to at most +maxlen+
	### characters. Returns the unchanged +string+ if it's not longer than +maxlen+.
	def truncate_string( string, maxlen )
		return string unless string.length > maxlen
		return string[ 0, maxlen - 3 ] + '...'
	end

end # class Chione::Component
