# -*- ruby -*-
#encoding: utf-8

require 'set'
require 'loggability'

require 'chione' unless defined?( Chione )


# An expression of component-matching criteria used to find entities that should be
# processed by a System.
class Chione::Aspect
	extend Loggability


	# Loggability API -- log to the chione logger
	log_to :chione


	### Return a new Aspect that will match entities with at least one of the specified
	### +component_types+.
	def self::with_one_of( *component_types )
		return self.new( one_of: component_types.flatten )
	end


	### Return a new Aspect that will match entities with all of the specified
	### +component_types+.
	def self::with_all_of( *component_types )
		return self.new( all_of: component_types.flatten )
	end


	### Return a new Aspect that will match entities with none of the specified
	### +component_types+.
	def self::with_none_of( *component_types )
		return self.new( none_of: component_types.flatten )
	end


	### Create a new empty Aspect
	def initialize( one_of: [], all_of: [], none_of: [] )
		@one_of  = Set.new( one_of )
		@all_of  = Set.new( all_of )
		@none_of = Set.new( none_of )
	end


	### Copy constructor.
	def initialize_copy( other )
		super
		@one_of  = @one_of.dup
		@all_of  = @all_of.dup
		@none_of = @none_of.dup
	end


	######
	public
	######

	# The Set of component types which matching entities must have at least one of.
	attr_reader :one_of

	# The Set of component types which matching entities must have all of.
	attr_reader :all_of

	# The Set of component types which matching entities must not have any of.
	attr_reader :none_of


	### Return a dup of this Aspect that also requires that matching entities have at least
	### one of the given +component_types+.
	def with_one_of( *component_types )
		return self.dup_with( one_of: component_types.flatten )
	end
	alias_method :and_one_of, :with_one_of


	### Return a dup of this Aspect that also requires that matching entities have all
	### of the given +component_types+.
	def with_all_of( *component_types )
		return self.dup_with( all_of: component_types.flatten )
	end
	alias_method :and_all_of, :with_all_of


	### Return a dup of this Aspect that also requires that matching entities have none
	### of the given +component_types+.
	def with_none_of( *component_types )
		return self.dup_with( none_of: component_types.flatten )
	end
	alias_method :and_none_of, :with_none_of


	### Returns true if the receiver is an empty aspect, i.e., matches all entities.
	def empty?
		return [ self.one_of, self.all_of, self.none_of ].all?( &:empty? )
	end


	### Return a human-readable String representation of the Aspect.
	def inspect
		parts = []
		parts << self.one_of_description
		parts << self.all_of_description
		parts << self.none_of_description
		parts.compact!

		str = "#<%p:%#0x matching entities" % [ self.class, self.object_id * 2 ]
		if parts.empty?
			str << " with any components"
		else
			str << parts.join( ', ' )
		end
		str << ">"

		return str
	end


	#########
	protected
	#########

	### Return a String describing the components matching entities must have at
	### least one of.
	def one_of_description
		return nil if self.one_of.empty?
		return " with at least one of: %s" % [ self.one_of.map(&:name).join(', ') ]
	end


	### Return a String describing the components matching entities must have all of.
	def all_of_description
		return nil if self.all_of.empty?
		return " with all of: %s" % [ self.all_of.map(&:name).join(', ') ]
	end


	### Return a String describing the components matching entities must not have any of.
	def none_of_description
		return nil if self.none_of.empty?
		return " with none of: %s" % [ self.none_of.map(&:name).join(', ') ]
	end


	### Return a copy of the receiver with the specified additional +required+ and
	### +excluded+ components.
	def dup_with( one_of: [], all_of: [], none_of: [] )
		self.log.debug "Making dup of %p with one_of: %p, all_of: %p, none_of: %p" %
			[ self, one_of, all_of, none_of ]

		copy = self.dup
		copy.one_of.merge( one_of )
		copy.all_of.merge( all_of )
		copy.none_of.merge( none_of )

		self.log.debug "  dup is: %p" % [ copy ]
		return copy
	end

end # class Chione::Aspect
