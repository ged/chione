# -*- ruby -*-
#encoding: utf-8

require 'loggability'
require 'securerandom'

require 'chione' unless defined?( Chione )

# The Entity (identity) class
class Chione::Entity
	extend Loggability

	# Loggability API -- send logs to the Chione logger
	log_to :chione


	### Return an ID for an Entity.
	def self::make_new_id
		return Chione.uuid.generate
	end


	### Create a new Entity for the specified +world+, and use the specified +id+ if
	### given. If no +id+ is given, one will be automatically generated.
	def initialize( world, id=nil )
		@world      = world
		@id         = id || self.class.make_new_id
		@components = {}
	end


	######
	public
	######

	# The Entity's ID
	attr_reader :id

	# The World the Entity belongs to
	attr_reader :world

	##
	# The Hash of this entity's Components
	attr_reader :components


	### Add the specified +component+ to the entity. It will replace any existing component
	### of the same type.
	def add_component( component )
		self.components[ component.class ] = component
		self.world.add_component_for( self, component )
	end


	### Fetch the first Component of the specified +types+ that belongs to the entity. If the
	### Entity doesn't have any of the specified types of Component, raises a KeyError.
	def get_component( *types )
		found_type = types.find {|type| self.components[type] } or
			raise KeyError, "entity %s doesn't have any of %p" % [ self.id, types ]
		return self.components[ found_type ]
	end


	### Returns +true+ if this entity has the specified +component+.
	def has_component?( component )
		return self.components.key?( component )
	end


	### Return the Entity as a human-readable string suitable for debugging.
	def inspect
		return "#<%p:%0#x ID=%s (%s)>" % [
			self.class,
			self.object_id * 2,
			self.id,
			self.components.keys.map( &:name ).sort.join( '+' )
		]
	end

end # class Chione::Entity
