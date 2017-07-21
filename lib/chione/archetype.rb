# -*- ruby -*-
#encoding: utf-8

require 'pluggability'
require 'loggability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'


# An Archetype mixin for defining factories for common entity configurations.
module Chione::Archetype
	extend Loggability,
	       Pluggability

	# Loggability API -- log to the chione logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/archetype' directory
	plugin_prefixes 'chione/archetype', 'chione/assemblage'


	### Extension callback -- add archetype functionality to an extended +object+.
	def self::extended( object )
		object.extend( Loggability )
		# object.extend( Chione::Inspection )
		object.extend( Chione::MethodUtilities )

		super

		object.log_to( :chione )
		object.components ||= {}
		object.singleton_attr_accessor :from_aspect
	end


	### Create an anonymous Archetype Module that will create entities which match
	### the specified +aspect+ (Chione::Aspect).
	def self::from_aspect( aspect )
		mod = Module.new
		mod.extend( self )
		mod.from_aspect = aspect

		aspect.all_of.each( &mod.method(:add) )
		mod.add( aspect.one_of.first ) unless aspect.one_of.empty?

		return mod
	end


	### Inclusion callback -- add the components from this archetype to those in
	### the specified +mod+.
	def included( mod )
		super
		self.log.debug "Including %d components in %p" % [ self.components.length, mod ]
		self.components.each do |component_type, args|
			self.log.debug "Adding %p to %p from %p" % [ component_type, mod, self ]
			mod.add( component_type, *args )
		end
	end


	##
	# The Hash of component types and initialization values to add to entities
	# constructed by this Archetype.
	attr_accessor :components


	### Add a +component_type+ to the list used when constructing a new entity from
	### the current Archetype. The component will be instantiated using the specified
	### +init_args+.
	def add( component_type, *init_args )
		self.components[ component_type ] = init_args
	end


	### Construct a new entity for the specified +world+ with all of the archetype's
	### components.
	def construct_for( world )
		entity = world.create_blank_entity
		self.components.each do |component_type, args|
			component = component_type.new( *args )
			world.add_component_to( entity, component )
		end

		return entity
	end


	### Return a human-readable representation of the object suitable for debugging.
	def inspect
		return "#<%p:%#016x %s>" % [
			self.class,
			self.object_id * 2,
			self.inspect_details,
		]
	end


	#########
	protected
	#########

	### Provide details about the Archetype for #inspect output.
	def inspect_details
		if self.from_aspect
			return "Chione::Archetype from %p" % [ self.from_aspect ]
		else
			return "Chione::Archetype for creating entities with %s" %
				[ self.components.keys.map( &:name ).join(', ') ]
		end
	end


end # module Chione::Archetype


