# Release History for chione

---
## v0.12.0 [2023-05-10] Michael Granger <ged@faeriemud.org>

Enhancements:

- Add fields to inherited component classes
- Update for Ruby 3


## v0.11.0 [2020-03-03] Michael Granger <ged@FaerieMUD.org>

Improvements:

- Tweak timing loop settings
- Update for Ruby 2.7


## v0.10.0 [2018-07-20] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add World#status.

Bugfixes:

- Fixed deprecation code for Assemblage.


## v0.9.0 [2018-07-19] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Make component fields more flexible.
- Add DataUtilities mixin


## v0.8.0 [2018-07-18] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add the equality operator to Chione::Entity.


## v0.7.0 [2018-07-11] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add a convenience method for creating Aspects that will match Archetypes


## v0.6.0 [2018-07-05] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add dependency-injection to Chione::System
- Set the thread name of the main world thread


##  v0.5.0 [2018-06-02] Michael Granger <ged@FaerieMUD.org>

Bugfixes:

- Fix blank archetype inspect details

Changes:

- Update configuration to use chione namespace. The `gameworld` config section
  is now `world` under the `chione` section.


## v0.4.0 [2017-12-11] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add caching and #inserted/#removed callbacks for aspect-membership to Systems.
- Add Aspect#archetype and Archetype.from_aspect
- Add Aspect#matches? to match individual entities
- Add fixtures collection
- Normalize entity IDs in the World API
- Add constructor arguments to component-creation paths
- Add the entity ID to Component's inspect output
- Add Chione::IteratingSystem
- Entities are thinner and systems make better use of named aspects
- Added World#remove_system and _manager; publish the instance of /added and
  /removed events
- Pull up common #inspect functionality into a mixin and use it everywhere.

Changes:

- The `every_tick` callback is now only passed the delta and the tick count
- Init arguments are passed through to Component.add_component
- Add a processing block to Component field declaration
- Rename some component-API methods on the World for clarity (with aliases to
  the old methods)
- Add the entity ID to components on registration
- Event handler declarations no longer include an aspect.

Bugfixes:

- Fix API docs for Chione::System::on



##  v0.3.0 [2017-05-31] Michael Granger <ged@FaerieMUD.org>

Changes:

- Rename Assemblage to Archetype to follow Artemis's naming.
- Rename Entity#get_component to #find_component to more accurately
  reflect what it does. Aliased to the old name for backward
  compatibility, but the alias will likely be removed before 1.0.

Enhancements:

- Add a Chione::Component() coercion method
- Allow a component to be added to an entity by name or class
- Add an #entities method to System for easy iteration by subclasses.
- Change the return value of World#entities_for to an Enumerator for
  future optimizations.

Bugfixes:

- Add a missing private method to Component


##  v0.2.0 [2017-05-26] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Make Assemblage, Component, Manager and System all pluggable.
- Don't assume the process model of Systems
- Extract a method for creating blank Entities to facilitate
  overriding which Entity class is used.
- Defer event processing until the event loop so events which are
  published at startup aren't missed.
- Allow shorthand required component list for system aspects


##  v0.1.0 [2017-05-22] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Refactor the World start/stop logic to make it easier to override in
  implementations which have their own process models.
- Allow a component's default to be generated by a callable

Bugfixes:

- Stringify the Manager or System class in `manager/added` and `system/added`
  events.


## v0.0.3 [2017-01-04] Michael Granger <ged@FaerieMUD.org>

Enhancements:

- Add a proper #inspect to Component

Bugfixes:

- Fix misnamed attr in World, update to latest Configurability syntax
- Fix some documentation typos.


## v0.0.2 [2015-07-13] Michael Granger <ged@FaerieMUD.org>

Fix a couple of build problems.


## v0.0.1 (unreleased) [2015-07-13] Michael Granger <ged@FaerieMUD.org>

Initial release.

