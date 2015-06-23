#!/usr/bin/env ruby

require 'benchmark'

# This is to figure out what the performance characteristics are of File.fnmatch
# vs. a regexp.

ITERATIONS = 5_000_000


SCENARIOS = [
	{
		event: 'foo',
		re: %r{^[^/]+$},
		fn: '*',
	},
	{
		event: 'foo/bar',
		re: %r{^foo/[^/]+$},
		fn: 'foo/*',
	},
	{
		event: 'foo/bar/baz',
		re: %r{^foo(/[^/]+)*$},
		fn: 'foo/**/*',
	},

]

Benchmark.bm do |bench|
	SCENARIOS.each do |scenario|
		event, re, fn = scenario.values_at( :event, :re, :fn )
		bench.report( "Regex (#{event})") { ITERATIONS.times { re.match(event) } }
		bench.report( "Fnmatch (#{event})" ) do
			ITERATIONS.times { File.fnmatch(fn, event, File::FNM_EXTGLOB|File::FNM_PATHNAME) }
		end
	end
end


