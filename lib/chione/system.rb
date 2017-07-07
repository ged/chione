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


	### Declare a block that is called once for each entity that matches the aspect
	### with the specified +aspect_name+ whenever an event matching +event_name+ is
	### broadcast to the World. The block will be called with the entity and a Hash
	### of the Components belonging to the entity that match the named Aspect.
	def self::on( event_name, with: :default, &block )
		raise LocalJumpError, "no block given" unless block

		aspect = self.aspects[ with ] or
			raise "No Aspect named '%s' for %p" % [ with, self.name ]

		method_name = "on_%s_with_%s" % [ event_name.tr('/', '_'), with ]
		define_method( method_name, &block )

		self.event_handlers << [ event_name, method_name ]
	end


	### Declare a block that is called once every tick for each entity that matches the given
	### +aspect+.
	def self::every_tick( with: :default, &block )
		return self.on( 'timing', with: with, &block )
	end


	### Add some per-subclass data structures to inheriting +subclass+es.
	def self::inherited( subclass )
		super
		subclass.instance_variable_set( :@aspects, DEFAULT_ASPECT_HASH.clone )
		subclass.instance_variable_set( :@event_handlers, [] )
	end


	### Create a new Chione::System for the specified +world+.
	def initialize( world, * )
		@world  = world
	end


	######
	public
	######

	##
	# The World which the System belongs to
	attr_reader :world


	### Start the system.
	def start
		self.log.info "Starting the %p" % [ self.class ]
		self.class.event_handlers.each do |event_name, method_name|
			callback = self.method( method_name )
			self.log.info "Registering %p as a callback for '%s' events." % [ callback, event_name ]
			self.world.subscribe( event_name, callback )
		end
	end


	### Stop the system.
	def stop
		self.class.event_handlers.each_value do |method_name|
			callback = self.method( method_name )
			self.log.info "Unregistering subscription for %p." % [ callback ]
			self.world.unsubscribe( callback )
		end
	end


	### Return an Enumerator that yields the entities which match the given +aspect_name+.
	def entities( aspect_name=:default )
		aspect = self.class.aspects[ aspect_name ] or
			raise "This system doesn't have a %s aspect!" % [ aspect_name ]

		set = self.world.entities_with( aspect )

		return set.to_enum( :each )
	end


	#########
	protected
	#########

	### Return the detail part of the inspection string.
	def inspect_details
		return "for %p:%#016x" % [ self.world.class, self.world.object_id * 2 ]
	end

end # class Chione::System
