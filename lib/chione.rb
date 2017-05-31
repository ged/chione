# -*- ruby -*-
#encoding: utf-8

require 'uuid'
require 'loggability'
require 'deprecatable'

Deprecatable.options.has_at_exit_report = false

# An Entity/Component System inspired by Artemis
module Chione
	extend Loggability

	# Gem version
	VERSION = '0.2.0'


	# Loggability API -- set up a log host
	log_as :chione


	require 'chione/mixins'

	autoload :Aspect,     'chione/aspect'
	autoload :Archetype,  'chione/archetype'
	autoload :Component,  'chione/component'
	autoload :Entity,     'chione/entity'
	autoload :Manager,    'chione/manager'
	autoload :System,     'chione/system'
	autoload :World,      'chione/world'

	##
	# The global UUID object for generating new UUIDs
	class << self; attr_reader :uuid ; end
	@uuid = UUID.new


	### Coerce the specified +object+ into a Chione::Component and return it.
	def self::Component( object )
		return object if object.is_a?( Chione::Component )
		return Chione::Component.create( object ) if
			object.is_a?( Class ) || object.is_a?( String ) || object.is_a?( Symbol )
		raise TypeError, "can't convert %p into Chione::Component" % [ object.class ]
	end


	### Warn about deprecated constants.
	def self::const_missing( name )
		super unless name == :Assemblage
		warn "Chione::Assemblage has been renamed to Chione::Archetype. " \
			"This alias will be removed before 1.0\n" \
			"Used at #{caller(1).first}"
		return Chione::Archetype
	end

end # module Chione

# vim: set nosta noet ts=4 sw=4:

