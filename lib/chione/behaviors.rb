# -*- ruby -*-
#encoding: utf-8

require 'rspec'
require 'chione'


RSpec.shared_examples "a Chione Component" do |args|

	if args.key?( :with_fields )

		args[:with_fields].each do |field|

			it "declares a #{field} field" do
				expect( described_class.fields ).to include( field.to_sym )
			end

		end

	else

		it "declares one or more fields" do
			expect( described_class.fields ).to_not be_empty
		end

	end

end



