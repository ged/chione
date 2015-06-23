#!/usr/bin/ruby -*- ruby -*-

$LOAD_PATH.unshift( 'lib' )

require 'configurability'
require 'loggability'
require 'pathname'

begin
	require 'chione'

	Loggability.level = :debug
	Loggability.format_with( :color )

rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


