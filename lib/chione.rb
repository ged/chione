# -*- ruby -*-
#encoding: utf-8

require 'uuid'
require 'loggability'

# An Entity/Component System inspired by Artemis
module Chione
	extend Loggability

	# Loggability API -- set up a log host
	log_as :chione


	# Gem version
	VERSION = '0.0.3'


	require 'chione/mixins'

	autoload :Aspect,     'chione/aspect'
	autoload :Assemblage, 'chione/assemblage'
	autoload :Component,  'chione/component'
	autoload :Entity,     'chione/entity'
	autoload :Manager,    'chione/manager'
	autoload :System,     'chione/system'
	autoload :World,      'chione/world'

	##
	# The global UUID object for generating new UUIDs
	class << self; attr_reader :uuid ; end
	@uuid = UUID.new

end # module Chione

# vim: set nosta noet ts=4 sw=4:

