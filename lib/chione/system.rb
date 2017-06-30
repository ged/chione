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


	# Loggability API -- send logs to the Chione logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/system' directory
	plugin_prefixes 'chione/system'


	##
	# The Hash of Chione::Aspects that describe entities this system is interested
	# in, keyed by name (a Symbol). A System which declares no aspects will have a
	# +:default+ Aspect which matches all entities.
	singleton_attr_reader :aspects


	### Add the specified +component_types+ to the Aspect of this System as being
	### required in any entities it processes.
	def self::aspect( name, *required, all_of: nil, one_of: nil, none_of: nil )
		aspect = Chione::Aspect.new

		all_of = required + Array( all_of )

		aspect = aspect.with_all_of( all_of )
		aspect = aspect.with_one_of( one_of )   if one_of
		aspect = aspect.with_none_of( none_of ) if none_of

		self.aspects.delete( :default )
		self.aspects[ name ] = aspect
	end


	### Add some per-subclass data structures to inheriting +subclass+es.
	def self::inherited( subclass )
		super
		subclass.instance_variable_set( :@aspects, {default: Chione::Aspect.new} )
	end


	### Create a new Chione::System for the specified +world+.
	def initialize( world, * )
		@world  = world
	end


	######
	public
	######

	# The World which the System belongs to
	attr_reader :world


	### Start the system.
	def start
		self.log.info "Starting the %p" % [ self.class ]
	end


	### Stop the system.
	def stop
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
