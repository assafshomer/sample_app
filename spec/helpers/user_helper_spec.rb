require 'spec_helper'

describe UsersHelper do

	describe "reverse_string_case" do
		it "should change casing" do
			reverse_string_case("asSaF").should_not == "asSaF"
		end
	end 
	
end