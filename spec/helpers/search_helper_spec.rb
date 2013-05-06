require 'spec_helper'

describe SearchHelper do
  describe "generating the correct search term" do
    it "should be nil if no fields" do
      generate_sql("foo")[0].should be_nil
    end
    it "should work with 1 search field" do
      generate_sql("foo", 'bar').should ==["bar LIKE ? ", "%foo%"]
    end          
    it "should work with 3 search fields" do
      generate_sql("foo", 'bar', 'baz', 'quux').should ==
      ["bar LIKE ?  OR baz LIKE ?  OR quux LIKE ? ", "%foo%", "%foo%", "%foo%"]
    end
    it "should work with 2 search fields and 2 search terms" do
      generate_sql("foo bar", 'buz', 'quux').should ==
      ["buz LIKE ?  OR buz LIKE ?  OR quux LIKE ?  OR quux LIKE ? ", "%foo%", "%bar%", "%foo%", "%bar%"]
    end
    it "should collapse duplicates" do
      generate_sql("foo foo foo buz buz foo", 'bar').should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end
    it "should collapse duplicates up to case" do
      generate_sql("foo FoO Foo buZ BUZ fOo", 'bar').should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end                         
  end
end