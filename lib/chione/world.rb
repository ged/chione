# -*- ruby -*-
#encoding: utf-8

require 'set'
require 'loggability'
require 'configurability'

require 'chione' unless defined?( Chione )

# The main ECS container
class Chione::World
	extend Loggability,
	       Configurability

	# Loggability API -- send logs to the Chione logger
	log_to :chione


	# Default config tunables
	CONFIG_DEFAULTS = {
		max_stop_wait: 5,
		timing_event_interval: 1,
	}


	### Create a new Chione::World
	def initialize
		@entities      = {}
		@systems       = {}
		@managers      = {}

		@subscriptions = {}

		@main_thread   = nil
		@world_threads = ThreadGroup.new

		@entities_by_component = Hash.new {|h,k| h[k] = Set.new }

		@max_stop_wait         = CONFIG_DEFAULTS[:max_stop_wait]
		@timing_event_interval = CONFIG_DEFAULTS[:timing_event_interval]
		@timing_event_count = 0

		# Load config values
		self.extend( Configurability )
	end


	######
	public
	######

	# Configurable: The maximum number of seconds to wait for any one System
	# or Manager thread to exit when shutting down.
	attr_accessor :max_stop_wait

	# Configurable: The number of seconds between timing events.
	attr_accessor :timing_event_interval

	# The number of times the event loop has executed.
	attr_reader :timing_event_count

	# The Hash of all Entities in the World, keyed by ID
	attr_reader :entities

	# The Hash of all Systems currently in the World, keyed by class.
	attr_reader :systems

	# The Hash of all Managers currently in the World, keyed by class.
	attr_reader :managers

	# The ThreadGroup that contains all Threads managed by the World.
	attr_reader :world_threads

	# The Thread object running the World's IO reactor loop
	attr_reader :io_thread


	### Configurability API -- configure the GameWorld.
	def configure( config=nil )
		config = self.defaults.merge( config || {} )

		self.max_stop_wait = config[:max_stop_wait]
		self.timing_event_interval = config[:timing_event_interval]
	end


	### Return the name of the section that should be used to configure new
	### GameWorlds.
	def config_key
		return 'gameworld'
	end


	### Start the world; returns the Thread in which the world is running.
	def start
		@main_thread = Thread.new do
			Thread.current.abort_on_exception = true
			self.log.info "Main thread (%s) started." % [ Thread.current ]
			@world_threads.add( Thread.current )
			@world_threads.enclose

			self.start_managers
			self.start_systems

			self.timing_loop
			self.log.info "Done with the timing loop."
		end

		self.log.info "Started main World thread: %p" % [ @main_thread ]
		return @main_thread
	end


	### Start any Managers registered with the world.
	def start_managers
		self.log.info "Starting %d Managers" % [ self.managers.length ]
		self.managers.each do |manager_class, mgr|
			self.log.debug "  starting %p" % [ manager_class ]
			start = Time.now
			mgr.start
			finish = Time.now
			self.log.debug "  started in %0.5fs" % [ finish - start ]
		end
	end


	### Start any Systems registered with the world.
	def start_systems
		self.log.info "Starting %d Systems" % [ self.systems.length ]
		self.systems.each do |system_class, sys|
			self.log.debug "  starting %p" % [ system_class ]
			start = Time.now
			sys.start
			finish = Time.now
			self.log.debug "  started in %0.5fs" % [ finish - start ]
		end
	end


	### Returns +true+ if the World has been started (but is not necessarily running yet).
	def started?
		return @main_thread && @main_thread.alive?
	end


	### Returns +true+ if the World is running (i.e., if #start has been called)
	def running?
		return self.started? && self.timing_event_count.nonzero?
	end


	### Stop the world.
	def stop
		self.systems.each {|_, sys| sys.stop }
		self.managers.each {|_, mgr| mgr.stop }

		self.world_threads.list.each do |thr|
			next if thr == @main_thread
			thr.join( self.max_stop_wait )
		end

		self.stop_timing_loop
	end


	### Halt the main timing loop. By default, this just kills the world's main thread.
	def stop_timing_loop
		@main_thread.kill
	end


	### Subscribe to events with the specified +event_name+. Returns the callback object
	### for later unsubscribe calls.
	def subscribe( event_name, callback=nil )
		callback = Proc.new if !callback && block_given?
		raise LocalJumpError, "no callback given" unless callback
		raise ArgumentError, "callback is not callable" unless callback.respond_to?( :call )
		raise ArgumentError, "callback has wrong arity" unless
			callback.arity >= 2 || callback.arity < 0

		@subscriptions[ event_name ] = callback

		return callback
	end


	### Unsubscribe from events that publish to the specified +callback+.
	def unsubscribe( callback )
		@subscriptions.delete_if {|_,val| val == callback }
	end


	### Publish an event with the specified +event_name+, calling any subscribers with
	### the specified +payload+.
	def publish( event_name, *payload )
		self.log.debug "Publishing a %p event: %p" % [ event_name, payload ]
		@subscriptions.each_key do |pattern|
			next unless File.fnmatch?( pattern, event_name, File::FNM_EXTGLOB|File::FNM_PATHNAME )
			begin
				@subscriptions[ pattern ].call( event_name, payload )
			rescue => err
				self.log.error "%p while calling the callback for a %p event: %s" %
					[ err.class, event_name, err.message ]
				@subscriptions.delete( pattern )
			end
		end
	end


	### Return a new Chione::Entity for the receiving World.
	def create_entity( assemblage=nil )
		entity = if assemblage
				assemblage.construct_for( self )
			else
				Chione::Entity.new( self )
			end

		@entities[ entity.id ] = entity

		self.publish( 'entity/created', entity )
		return entity
	end


	### Destroy the specified entity and remove it from any registered
	### systems/managers.
	def destroy_entity( entity )
		self.publish( 'entity/destroyed', entity )
		@entities_by_component.each_value {|set| set.delete(entity) }
		@entities.delete( entity.id )
	end


	### Register the specified +component+ as having been added to the specified
	### +entity+.
	def add_component_for( entity, component )
		@entities_by_component[ component.class ].add( entity )
	end


	### Return an Array of all entities that match the specified +aspect+.
	def entities_with( aspect )
		initial_set = if aspect.one_of.empty?
				@entities_by_component.values
			else
				@entities_by_component.values_at( *aspect.one_of )
			end

		with_one = initial_set.reduce( :| )
		with_all = @entities_by_component.values_at( *aspect.all_of ).reduce( with_one, :& )
		without_any = @entities_by_component.values_at( *aspect.none_of ).reduce( with_all, :- )

		return without_any
	end


	### Add an instance of the specified +system_type+ to the world and return it.
	### It will replace any existing system of the same type.
	def add_system( system_type, *args )
		system_obj = system_type.new( self, *args )
		@systems[ system_type ] = system_obj

		if self.running?
			self.log.info "Starting %p added to running world." % [ system_type ]
			system_obj.start
		end

		self.publish( 'system/added', system_type.name )
		return system_obj
	end


	### Add an instance of the specified +manager_type+ to the world and return it.
	### It will replace any existing manager of the same type.
	def add_manager( manager_type, *args )
		manager_obj = manager_type.new( self, *args )
		@managers[ manager_type ] = manager_obj

		if self.running?
			self.log.info "Starting %p added to running world." % [ manager_type ]
			manager_obj.start
		end

		self.publish( 'manager/added', manager_type.name )
		return manager_obj
	end


	#########
	protected
	#########

	### The loop the main thread executes after the world is started. The default
	### implementation just broadcasts the +timing+ event, so will likely want to
	### override this if the main thread should do something else.
	def timing_loop
		self.log.info "Starting timing loop."
		last_timing_event = Time.now
		@timing_event_count = 0

		loop do
			previous_time, last_timing_event = last_timing_event, Time.now

			self.publish( 'timing', last_timing_event - previous_time, @timing_event_count )

			@timing_event_count += 1
			remaining_time = self.timing_event_interval - (Time.now - last_timing_event)

			if remaining_time > 0
				sleep( remaining_time )
			else
				self.log.warn "Timing loop %d exceeded `timing_event_interval` (by %0.6fs)" %
					[ @timing_event_count, remaining_time.abs ]
			end
		end

	ensure
		self.log.info "Exiting timing loop."
	end


end # class Chione::World

