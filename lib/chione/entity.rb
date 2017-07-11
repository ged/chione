# -*- ruby -*-
#encoding: utf-8

require 'deprecatable'
require 'loggability'
require 'securerandom'

require 'chione' unless defined?( Chione )
require 'chione/mixins'

# The Entity (identity) class
class Chione::Entity
	extend Loggability,
	       Deprecatable

	include Chione::Inspection

	# Loggability API -- send logs to the Chione logger
	log_to :chione


	### Return an ID for an Entity.
	def self::make_new_id
		return Chione.uuid.generate
	end


	### Create a new Entity for the specified +world+, and use the specified +id+ if
	### given. If no +id+ is given, one will be automatically generated.
	def initialize( world, id=nil )
		@world = world
		@id    = id || self.class.make_new_id
	end


	######
	public
	######

	# The Entity's ID
	attr_reader :id

	# The World the Entity belongs to
	attr_reader :world


	### Return the components that the entity's World has registered for it as a Hash
	### keyed by the Component class.
	def components
		return self.world.components_for( self )
	end


	### Add the specified +component+ to the entity. The +component+ can be a
	### subclass of Chione::Component, an instance of such a subclass, or the name
	### of a subclass. It will replace any existing component of the same type.
	def add_component( component )
		self.world.add_component_to( self, component )
	end


	### Fetch the component of the specified +component_class+ that corresponds with the
	### receiving entity. Returns +nil+ if so much component exists.
	def get_component( component_class )
		return self.world.get_component_for( self, component_class )
	end


	### Remove the component of the specified +component_class+ that corresponds with the
	### receiving entity. Returns the component instance if it was removed, or +nil+ if no
	### Component of the specified type was registered to the entity.
	def remove_component( component_class )
		return self.world.remove_component_from( self, component_class )
	end


	### Returns +true+ if this entity has a component of the specified +component_class+.
	def has_component?( component_class )
		return self.world.has_component_for?( self, component_class )
	end


	#########
	protected
	#########

	### Return the detailed part of the Entity's #inspect output
	def inspect_details
		return "ID=%s (%s)" % [
			self.id,
			self.components.keys.map( &:name ).sort.join( '+' )
		]
	end

end # class Chione::Entity
