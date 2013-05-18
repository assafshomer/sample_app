require 'spec_helper'

describe SearchHelper do
  describe "generate_sql" do
    it "should be nil if no fields" do
      generate_sql("foo",'',nil)[0].should be_nil
    end
    it "should work with 1 search field" do
      generate_sql("foo", 'bar', nil).should ==["bar LIKE ? ", "%foo%"]
    end          
    it "should work with 3 search fields" do
      generate_sql("foo", 'bar baz quux',nil).should ==
      ["bar LIKE ?  OR baz LIKE ?  OR quux LIKE ? ", "%foo%", "%foo%", "%foo%"]
    end
    it "should work with 2 search fields and 2 search terms" do
      generate_sql("foo bar", 'buz quux',nil).should ==
      ["buz LIKE ?  OR buz LIKE ?  OR quux LIKE ?  OR quux LIKE ? ", "%foo%", "%bar%", "%foo%", "%bar%"]
    end
    it "should collapse duplicates" do
      generate_sql("foo foo foo buz buz foo", 'bar',nil).should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end
    it "should collapse duplicates up to case" do
      generate_sql("foo FoO Foo buZ BUZ fOo", 'bar',nil).should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end
    it "should truncate search terms after 41 characters" do
      generate_sql("f"*50, 'bar',nil).should == generate_sql("f"*40, 'bar',nil)      
      generate_sql("f"*50, 'bar',nil).should_not == generate_sql("f"*39, 'bar',nil)
    end 
    it "should not include an illegal field" do
      generate_sql('foo bar', 'name email buz',User).should == generate_sql('foo bar', 'name email',User)
    end                               
  end

  describe "extract_minimal_search_terms" do
    it "should truncate duplicates" do
      extract_minimal_search_terms(['a','a','b','b','a','c']).should == ['a','b','c']
    end
    it "ignore case" do
      extract_minimal_search_terms(%w(aa aA Aa AA)).should ==['aa']
    end
    it "should not choke on empty array" do
      extract_minimal_search_terms([]).should == []
    end
  end

  describe "wrap_with_percent" do
    it "should wrap with percent" do
      wrap_with_percent(%w(assaf shomer)).should == ['%assaf%','%shomer%']  
    end    
    it "should not wrap an empty array" do
      wrap_with_percent([]).should == []
    end
  end

  describe "extract_legal_fields" do
    it "should include legal fields only" do
      extract_legal_fields('name foo bar',User).should == ['name']  
    end
    
  end

end