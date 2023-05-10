# -*- ruby -*-

require 'chione'
require 'chione/system'



# Process all entities matching an aspect iteratively for every World timing
# loop iteration.
class Chione::IteratingSystem < Chione::System


	every_tick do |*|
		world = self.world

		self.class.aspects.each do |name, aspect|
			self.log.debug "Iterating over entities with '%s'" % [ name ]
			world.entities_with( aspect ).each do |entity|
				self.process( name, entity, world.components_for(entity) )
			end
		end

	end


	### Process the given +components+ (which match the system's Aspect) for the
	### specified +entity_id+. Concrete subclasses are required to override this.
	def process( aspect_name, entity_id, components )
		raise NotImplementedError, "%p does not implement #%s" % [ self.class, __method__ ]
	end


end # class Chione::IteratingSystem

