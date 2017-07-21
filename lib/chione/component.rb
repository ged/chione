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


	### Declare a field for the component named +name+, with a default value of
	### +default+. If the optional +process_block+ is provided, it will be called
	### with the new value being assigned to the field before it is set, and the
	### return value of it will be used instead.
	def self::field( name, default: nil, &process_block )
		self.fields ||= {}
		self.fields[ name ] = default

		define_method( "process_#{name}", &process_block ) if process_block
		define_method( "#{name}=" ) do |new_val|
			new_val = self.send( "process_#{name}", new_val ) if self.respond_to?( "process_#{name}" )
			self.instance_variable_set( "@#{name}", new_val )
		end

		attr_reader( name )
	end


	### Create a new component with the specified +values+.
	def initialize( entity_id=nil, values={} )
		if entity_id.is_a?( Hash )
			values = entity_id
			entity_id = nil
		end

		@entity_id = entity_id

		if self.class.fields
			self.class.fields.each do |name, default|
				self.method( "#{name}=" ).call( values[name] || default_value(default) )
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

	### Process the given +default+ value so it's suitable for use as a default
	### attribute value.
	def default_value( default )
		return default.call( self ) if default.respond_to?( :call )
		return deep_copy( default )
	end


	### Make a deep copy of the specified +value+.
	def deep_copy( value )
		return Marshal.load( Marshal.dump(value) )
	end


	### Return a slice of the specified +string+ truncated to at most +maxlen+
	### characters. Returns the unchanged +string+ if it's not longer than +maxlen+.
	def truncate_string( string, maxlen )
		return string unless string.length > maxlen
		return string[ 0, maxlen - 3 ] + '...'
	end

end # class Chione::Component
