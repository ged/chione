# -*- ruby -*-
#encoding: utf-8

require 'loggability'

require 'chione' unless defined?( Chione )


# The Manager class
class Chione::Manager
	extend Loggability

	# Loggability API -- send logs to the Chione logger
	log_to :chione


	### Create a new Chione::Manager for the specified +world+.
	def initialize( world, * )
		@world = world
	end


	######
	public
	######

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

end # class Chione::Manager
