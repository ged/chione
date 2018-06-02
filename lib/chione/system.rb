# -*- ruby -*-
#encoding: utf-8

require 'pluggability'
require 'loggability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'
require 'chione/aspect'


# The System (behavior) class
class Chione::System
	extend Loggability,
	       Pluggability,
	       Chione::MethodUtilities

	include Chione::Inspection


	# A Hash that auto-vivifies only its :default key
	DEFAULT_ASPECT_HASH = Hash.new do |h,k|
		if k == :default
			h[k] = Chione::Aspect.new
		else
			nil
		end
	end


	# Loggability API -- send logs to the Chione logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/system' directory
	plugin_prefixes 'chione/system'


	##
	# The Hash of Chione::Aspects that describe entities this system is interested
	# in, keyed by name (a Symbol). A System which declares no aspects will have a
	# +:default+ Aspect which matches all entities.
	singleton_attr_reader :aspects

	##
	# Event handler tuples (event name, callback) that should be registered when the
	# System is started.
	singleton_attr_reader :event_handlers


	### Add the specified +component_types+ to the Aspect of this System as being
	### required in any entities it processes.
	def self::aspect( name, *required, all_of: nil, one_of: nil, none_of: nil )
		aspect = Chione::Aspect.new

		all_of = required + Array( all_of )

		aspect = aspect.with_all_of( all_of )
		aspect = aspect.with_one_of( one_of )   if one_of
		aspect = aspect.with_none_of( none_of ) if none_of

		self.aspects[ name ] = aspect
	end


	### Declare a block that is called once whenever an event matching +event_name+ is
	### broadcast to the World.
	def self::on( event_name, &block )
		raise LocalJumpError, "no block given" unless block
		raise ArgumentError, "callback has wrong arity" unless block.arity >= 2 || block.arity < 0

		method_name = "on_%s_event" % [ event_name.tr('/', '_') ]
		self.log.debug "Making handler method #%s for %s events out of %p" %
			[ method_name, event_name, block ]
		define_method( method_name, &block )

		self.event_handlers << [ event_name, method_name ]
	end


	### Declare a block that is called once every tick for each entity that matches the given
	### +aspect+.
	def self::every_tick( &block )
		return self.on( 'timing' ) do |event_name, payload|
			self.instance_exec( *payload, &block )
		end
	end


	### Add some per-subclass data structures to inheriting +subclass+es.
	def self::inherited( subclass )
		super
		subclass.instance_variable_set( :@aspects, DEFAULT_ASPECT_HASH.clone )
		subclass.instance_variable_set( :@event_handlers, self.event_handlers&.dup || [] )
	end


	### Create a new Chione::System for the specified +world+.
	def initialize( world, * )
		self.log.debug "Setting up %p" % [ self.class ]
		@world  = world
		@aspect_entities = self.class.aspects.each_with_object( {} ) do |(aspect_name, aspect), hash|
			matching_set = world.entities_with( aspect )
			self.log.debug "Initial Set with the %s aspect: %p" % [ aspect_name, matching_set]
			hash[ aspect_name ] = matching_set
		end
	end


	######
	public
	######

	##
	# The World which the System belongs to
	attr_reader :world

	##
	# The Hash of Sets of entity IDs which match the System's aspects, keyed by aspect name.
	attr_reader :aspect_entities


	### Start the system.
	def start
		self.log.info "Starting the %p system; %d event handlers to register" %
			[ self.class, self.class.event_handlers.length ]
		self.class.event_handlers.each do |event_name, method_name|
			callback = self.method( method_name )
			self.log.info "Registering %p as a callback for '%s' events." % [ callback, event_name ]
			self.world.subscribe( event_name, callback )
		end
	end


	### Stop the system.
	def stop
		self.class.event_handlers.each do |_, method_name|
			callback = self.method( method_name )
			self.log.info "Unregistering subscription for %p." % [ callback ]
			self.world.unsubscribe( callback )
		end
	end


	### Return an Enumerator that yields the entities which match the given +aspect_name+.
	def entities( aspect_name=:default )
		return self.aspect_entities[ aspect_name ].to_enum( :each )
	end


	### Entity callback -- called whenever an entity has a component added to it or
	### removed from it. Calls the appropriate callback (#inserted or #removed) if
	### the component change caused it to belong to or stop belonging to one of the
	### system's aspects.
	def entity_components_updated( entity_id, components_hash )
		self.class.aspects.each do |aspect_name, aspect|
			entity_ids = self.aspect_entities[ aspect_name ]

			if aspect.matches?( components_hash )
				self.inserted( aspect_name, entity_id, components_hash ) if
					entity_ids.add?( entity_id )
			else
				self.removed( aspect_name, entity_id, components_hash ) if
					entity_ids.delete?( entity_id )
			end
		end
	end


	### Entity callback -- called whenever an entity has a component added to it
	### that makes it start matching an aspect of the receiving System. The
	### +aspect_name+ is the name of the Aspect it now matches, and the +components+
	### are a Hash of the entity's components keyed by Class. By default this is a
	### no-op.
	def inserted( aspect_name, entity_id, components )
		self.log.debug "Entity %s now matches the %s aspect." % [ entity_id, aspect_name ]
	end


	### Entity callback -- called whenever an entity has a component removed from it
	### that makes it stop matching an aspect of the receiving System. The
	### +aspect_name+ is the name of the Aspect it no longer matches, and the
	### +components+ are a Hash of the entity's components keyed by Class. By
	### default this is a no-op.
	def removed( aspect_name, entity_id, components )
		self.log.debug "Entity %s no longer matches the %s aspect." % [ entity_id, aspect_name ]
	end


	#########
	protected
	#########

	### Return the detail part of the inspection string.
	def inspect_details
		return "for %p:%#016x" % [ self.world.class, self.world.object_id * 2 ]
	end

end # class Chione::System
