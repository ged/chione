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

	# Loggability API -- log to the 'chione' logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/component' directory
	plugin_prefixes 'chione/component'

	##
	# The Hash of fields implemented by the component
	singleton_attr_accessor :fields


	### Declare a field for the component named +name+, with a default value of
	### +default+.
	def self::field( name, default: nil )
		self.fields ||= {}
		self.fields[ name ] = default
		attr_accessor( name )
	end


	### Create a new component with the specified +values+.
	def initialize( values={} )
		if self.class.fields
			self.class.fields.each do |name, default|
				self.method( "#{name}=" ).call( values[name] || default_value(default) )
			end
		end
	end


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		fields_desc = self.fields_description
		return "#<%p:%#x %s>" % [ self.class, self.object_id * 2, fields_desc ]
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

end # class Chione::Component
