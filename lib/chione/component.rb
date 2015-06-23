# -*- ruby -*-
#encoding: utf-8

require 'chione' unless defined?( Chione )

# The Component (data) class
class Chione::Component

	# The Hash of fields implemented by the component
	class << self
		attr_accessor :fields
	end


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
				self.method( "#{name}=" ).call( values[name] || deep_copy(default) )
			end
		end
	end


	#######
	private
	#######

	### Make a deep copy of the specified +value+.
	def deep_copy( value )
		Marshal.load( Marshal.dump(value) )
	end

end # class Chione::Component
