# -*- ruby -*-
#encoding: utf-8

require 'pluggability'
require 'loggability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'


# The Manager class
class Chione::Manager
	extend Loggability,
	       Pluggability

	include Chione::Inspection


	# Loggability API -- send logs to the Chione logger
	log_to :chione

	# Pluggability API -- load subclasses from the 'chione/manager' directory
	plugin_prefixes 'chione/manager'


	### Create a new Chione::Manager for the specified +world+.
	def initialize( world, * )
		@world = world
	end


	######
	public
	######

	# The World which the Manager belongs to
	attr_reader :world


	### Start the Manager as the world is starting. Derivatives must implement this
	### method.
	def start
		raise NotImplementedError, "%p does not implement required method #start" % [ self.class ]
	end


	### Stop the Manager as the world is stopping. Derivatives must implement this
	### method.
	def stop
		raise NotImplementedError, "%p does not implement required method #stop" % [ self.class ]
	end


	#########
	protected
	#########

	### Return the detail part of the inspection string.
	def inspect_details
		return "for %p:%#016x" % [ self.world.class, self.world.object_id * 2 ]
	end


end # class Chione::Manager
