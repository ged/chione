# Simplecov config

SimpleCov.start do
	add_filter 'spec'
	add_filter 'integration'
	add_group "Needing tests" do |file|
		file.covered_percent < 90
	end

	if ENV['CIRCLE_ARTIFACTS']
		dir = ENV['CIRCLE_ARTIFACTS'] + "/coverage"
		coverage_dir( dir )
	end
end
