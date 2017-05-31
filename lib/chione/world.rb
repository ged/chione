# -*- ruby -*-
#encoding: utf-8

require 'set'
require 'loggability'
require 'configurability'

require 'chione' unless defined?( Chione )
require 'chione/mixins'


# The main ECS container
class Chione::World
	extend Loggability,
	       Configurability,
	       Chione::MethodUtilities

	# Loggability API -- send logs to the Chione logger
	log_to :chione

	# Configurability API -- use the 'gameworld' section of the config
	configurability :gameworld do

		##
		# :singleton-method:
		# Configurable: The maximum number of seconds to wait for any one System
		# or Manager thread to exit before killing it when shutting down.
		setting :max_stop_wait, default: 5

		##
		# :singleton-method:
		# Configurable: The number of seconds between timing events.
		setting :timing_event_interval, default: 1

	end



	### Create a new Chione::World
	def initialize
		@entities      = {}
		@systems       = {}
		@managers      = {}

		@subscriptions = Hash.new do |h,k|
			h[ k ] = Set.new
		end
		@defer_events  = true
		@deferred_events = []

		@main_thread   = nil
		@world_threads = ThreadGroup.new

		@entities_by_component = Hash.new {|h,k| h[k] = Set.new }

		@timing_event_count = 0
	end


	######
	public
	######

	##
	# The number of times the event loop has executed.
	attr_reader :timing_event_count

	##
	# The Hash of all Entities in the World, keyed by ID
	attr_reader :entities

	##
	# The Hash of all Systems currently in the World, keyed by class.
	attr_reader :systems

	##
	# The Hash of all Managers currently in the World, keyed by class.
	attr_reader :managers

	##
	# The ThreadGroup that contains all Threads managed by the World.
	attr_reader :world_threads

	##
	# The Thread object running the World's IO reactor loop
	attr_reader :main_thread

	##
	# The Hash of event subscription callbacks registered with the world, keyed by
	# event pattern.
	attr_reader :subscriptions

	##
	# Whether or not to queue published events instead of sending them to
	# subscribers immediately.
	attr_predicate_accessor :defer_events

	##
	# The queue of events that have not yet been sent to subscribers.
	attr_reader :deferred_events
	alias_method :deferring_events?, :defer_events?


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


	### Stop any Managers running in the world.
	def stop_managers
		self.log.info "Stopping managers."
		self.managers.each {|_, mgr| mgr.stop }
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


	### Stop any Systems running in the world.
	def stop_systems
		self.log.info "Stopping systems."
		self.systems.each {|_, sys| sys.stop }
	end


	### Returns +true+ if the World has been started (but is not necessarily running yet).
	def started?
		return @main_thread && @main_thread.alive?
	end


	### Returns +true+ if the World is running (i.e., if #start has been called)
	def running?
		return self.started? && self.timing_event_count.nonzero?
	end


	### Kill the threads other than the main thread in the world's thread list.
	def kill_world_threads
		self.log.info "Killing child threads."
		self.world_threads.list.each do |thr|
			next if thr == @main_thread
			self.log.debug "  killing: %p" % [ thr ]
			thr.join( self.class.max_stop_wait )
		end
	end


	### Stop the world.
	def stop
		self.stop_systems
		self.stop_managers
		self.kill_world_threads
		self.stop_timing_loop
	end


	### Halt the main timing loop. By default, this just kills the world's main thread.
	def stop_timing_loop
		self.log.info "Stopping the timing loop."
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

		self.subscriptions[ event_name ].add( callback )

		return callback
	end


	### Unsubscribe from events that publish to the specified +callback+.
	def unsubscribe( callback )
		self.subscriptions.keys.each do |pattern|
			cbset = self.subscriptions[ pattern ]
			cbset.delete( callback )
			self.subscriptions.delete( pattern ) if cbset.empty?
		end
	end


	### Publish an event with the specified +event_name+ and +payload+.
	def publish( event_name, *payload )
		# self.log.debug "Publishing a %p event: %p" % [ event_name, payload ]
		if self.defer_events?
			self.deferred_events.push( [event_name, payload] )
		else
			self.call_subscription_callbacks( event_name, payload )
		end
	end


	### Send any deferred events to subscribers.
	def publish_deferred_events
		while event = self.deferred_events.shift
			self.call_subscription_callbacks( *event )
		end
	end


	### Call the callbacks of any subscriptions matching the specified +event_name+ with
	### the given +payload+.
	def call_subscription_callbacks( event_name, payload )
		self.subscriptions.each do |pattern, callbacks|
			next unless File.fnmatch?( pattern, event_name, File::FNM_EXTGLOB|File::FNM_PATHNAME )

			callbacks.each do |callback|
				unless self.call_subscription_callback( callback, event_name, payload )
					self.log.debug "Callback failed; removing it from the subscription."
					self.unsubscribe( callback )
				end
			end
		end
	end


	### Call the specified +callback+ with the provided +event_name+ and +payload+, returning
	### +true+ if the callback executed without error.
	def call_subscription_callback( callback, event_name, payload )
		callback.call( event_name, payload )
		return true
	rescue => err
		self.log.error "%p while calling %p for a %p event: %s" %
			[ err.class, callback, event_name, err.message ]
		self.log.debug "  %s" % [ err.backtrace.join("\n  ") ]
		return false
	end


	### Return a new Chione::Entity for the receiving World, using the optional
	### +archetype+ to populate it with components if it's specified.
	def create_entity( archetype=nil )
		entity = if archetype
				archetype.construct_for( self )
			else
				self.create_blank_entity
			end

		@entities[ entity.id ] = entity

		self.publish( 'entity/created', entity.id )
		return entity
	end


	### Return a new Chione::Entity with no components for the receiving world.
	### Override this if you wish to use a class other than Chione::Entity for your
	### world.
	def create_blank_entity
		return Chione::Entity.new( self )
	end


	### Destroy the specified entity and remove it from any registered
	### systems/managers.
	def destroy_entity( entity )
		raise ArgumentError, "%p does not contain entity %p" % [ self, entity ] unless
			self.has_entity?( entity )

		self.publish( 'entity/destroyed', entity )
		@entities_by_component.each_value {|set| set.delete(entity) }
		@entities.delete( entity.id )
	end


	### Returns +true+ if the world contains the specified +entity+ or an entity
	### with +entity+ as the ID.
	def has_entity?( entity )
		if entity.respond_to?( :id )
			return @entities.key?( entity.id )
		else
			return @entities.key?( entity )
		end
	end


	### Register the specified +component+ as having been added to the specified
	### +entity+.
	def add_component_for( entity, component )
		self.log.debug "Adding %p for %p" % [ component.class, entity ]
		@entities_by_component[ component.class ].add( entity )
	end


	### Return an Enumerator of the Entities that have a Component composition that
	### is compatible with the specified +system+'s aspect.
	def entities_for( system )
		system = system.class unless system.is_a?( Class )
		return self.entities_with( system.aspect ).to_enum
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
	### implementation just broadcasts the +timing+ event, so you will likely want to
	### override this if the main thread should do something else.
	def timing_loop
		self.log.info "Starting timing loop."
		last_timing_event = Time.now
		interval = self.class.timing_event_interval
		self.defer_events = false
		@timing_event_count = 0

		loop do
			previous_time, last_timing_event = last_timing_event, Time.now

			self.publish( 'timing', last_timing_event - previous_time, @timing_event_count )
			self.publish_deferred_events

			@timing_event_count += 1
			remaining_time = interval - (Time.now - last_timing_event)

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

