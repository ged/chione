# -*- ruby -*-
#encoding: utf-8

require 'loggability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'
require 'chione/aspect'


# The System (behavior) class
class Chione::System
	extend Loggability,
	       Chione::MethodUtilities

	# Loggability API -- send logs to the Chione logger
	log_to :chione


	### Add the specified +component_types+ to the Aspect of this System as being
	### required in any entities it processes.
	def self::aspect( all_of: nil, one_of: nil, none_of: nil )
		@aspect ||= Chione::Aspect.new

		@aspect = @aspect.with_all_of( all_of )   if all_of
		@aspect = @aspect.with_one_of( one_of )   if one_of
		@aspect = @aspect.with_none_of( none_of ) if none_of

		return @aspect
	end
	singleton_method_alias :for_entities_that_have, :aspect


	### Create a new Chione::System for the specified +world+.
	def initialize( world, * )
		@world  = world
		@thread = nil
		@aspect = []
	end


	### Start the system.
	def start
		self.log.info "Starting the %p" % [ self.class ]
		@thread = Thread.new( &self.method(:process_loop) )
	end


	### Stop the system.
	def stop
		@thread.kill
	end


	### The main loop of the system -- process entities that this system is
	### interested in at an appropriate interval.
	def process_loop
		raise NotImplementedError, "%p does not implement required method #process_loop" %
			[ self.class ]
	end

end # class Chione::System
