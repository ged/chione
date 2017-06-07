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


	### Add the specified +component_types+ to the Aspect of this System as being
	### required in any entities it processes.
	def self::aspect( *required, all_of: nil, one_of: nil, none_of: nil )
		@aspect ||= Chione::Aspect.new

		all_of = required + Array( all_of )

		@aspect = @aspect.with_all_of( all_of )
		@aspect = @aspect.with_one_of( one_of )   if one_of
		@aspect = @aspect.with_none_of( none_of ) if none_of

		return @aspect
	end
	singleton_method_alias :for_entities_that_have, :aspect


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


	### Return an Enumerator that yields the entities which this system operators
	### over.
	def entities
		return self.world.entities_for( self )
	end


	#########
	protected
	#########

	### Return the detail part of the inspection string.
	def inspect_details
		return "for %p:%#016x" % [ self.world.class, self.world.object_id * 2 ]
	end

end # class Chione::System
