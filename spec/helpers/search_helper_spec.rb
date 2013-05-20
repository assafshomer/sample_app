require 'spec_helper'

describe SearchHelper do
  describe "generate_LIKE_sql" do
    it "should be nil if no fields" do
      generate_LIKE_sql("foo",'',nil)[0].should be_nil
    end
    it "should work with 1 search field" do
      generate_LIKE_sql("foo", 'bar', nil).should ==["bar LIKE ? ", "%foo%"]
    end          
    it "should work with 3 search fields" do
      generate_LIKE_sql("foo", 'bar baz quux',nil).should ==
      ["bar LIKE ?  OR baz LIKE ?  OR quux LIKE ? ", "%foo%", "%foo%", "%foo%"]
    end
    it "should work with 2 search fields and 2 search terms" do
      generate_LIKE_sql("foo bar", 'buz quux',nil).should ==
      ["buz LIKE ?  OR buz LIKE ?  OR quux LIKE ?  OR quux LIKE ? ", "%foo%", "%bar%", "%foo%", "%bar%"]
    end
    it "should collapse duplicates" do
      generate_LIKE_sql("foo foo foo buz buz foo", 'bar',nil).should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end
    it "should collapse duplicates up to case" do
      generate_LIKE_sql("foo FoO Foo buZ BUZ fOo", 'bar',nil).should ==
      ["bar LIKE ?  OR bar LIKE ? ", "%foo%", "%buz%"]
    end
    it "should truncate search terms after 41 characters" do
      generate_LIKE_sql("f"*50, 'bar',nil).should == generate_LIKE_sql("f"*40, 'bar',nil)      
      generate_LIKE_sql("f"*50, 'bar',nil).should_not == generate_LIKE_sql("f"*39, 'bar',nil)
    end 
    it "should not include an illegal field" do
      generate_LIKE_sql('foo bar', 'name email buz',User).should == generate_LIKE_sql('foo bar', 'name email',User)
    end                               
  end

  describe "extract_minimal_search_terms" do
    it "should truncate duplicates" do
      extract_minimal_search_terms('a a b b a c').should == ['a','b','c']
    end
    it "ignore case" do
      extract_minimal_search_terms('aa aA Aa AA').should ==['aa']
    end
    it "should not choke on empty string" do
      extract_minimal_search_terms('').should == []
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

  describe "generate_LIKE_query" do
    it "should work with one search term and one field" do
      generate_LIKE_query(['foo'],['bar']).should == 'bar LIKE ? '
    end
    it "should not choke on empty" do
      generate_LIKE_query([],['bar']).should be_blank
      generate_LIKE_query(['foo'],[]).should be_blank
      generate_LIKE_query([],[]).should be_blank
    end   
    it "should work with 2 search terms" do
      generate_LIKE_query(['foo','bar'],['baz','quux']).should == "baz LIKE ?  OR baz LIKE ?  OR quux LIKE ?  OR quux LIKE ? " 
    end 
  end

  describe "searching microposts by user name and email" do
    let!(:assaf) { FactoryGirl.create(:user, name: 'Assaf Shomer', email: 'assaf@shomer.com')}
    let!(:bill) { FactoryGirl.create(:user,name: 'bill Clingon', email: 'cling@hillary.com')}
    let!(:bob) { FactoryGirl.create(:user, name: 'Bob Jones') }
    let!(:mp1) { FactoryGirl.create(:micropost, user: assaf, content: 'post by assaf') }
    let!(:mp2) { FactoryGirl.create(:micropost, user: bill, content: 'post by bill') }
    let!(:mp3) { FactoryGirl.create(:micropost, user: bob, content: 'post by bob') }    
    describe "get_user_ids_by_name_and_email" do
      it "should return a string of user_ids with given name or email" do
        search_user_ids('assaf','name email').should == [assaf.id]
        search_user_ids('com','name email').should == [assaf.id,bill.id]
        search_user_ids('edu','name email').should == [bob.id]
        search_user_ids('blah','name email').should_not == [bob.id]
      end   
    end
    describe "get_microposts_by_user_id" do
      it "should find the microposts for one user" do
        get_microposts_by_user_id([assaf.id]).should include(mp1)        
      end
      it "should find the microposts for two users" do
        get_microposts_by_user_id([assaf.id,bob.id]).should include(mp1, mp3)
      end
      it "should be blank if no such user" do
        get_microposts_by_user_id([User.all.map(&:id).max+100]).should be_blank
      end
    end
    describe "generate_search_microposts_sql" do
      describe "should generate the correct sql" do
        it "with one search term" do
          generate_search_microposts_sql('assaf', 'content').should ==
           ['content LIKE ?  OR user_id IN (?)','%assaf%',[assaf.id]]
        end
        it "without field names" do
          generate_search_microposts_sql('assaf').should ==
           ['content LIKE ?  OR user_id IN (?)','%assaf%',[assaf.id]]
        end 
        it "with two search terms" do
          generate_search_microposts_sql('assaf edu').should ==
           ['content LIKE ?  OR content LIKE ?  OR user_id IN (?)', "%assaf%", "%edu%",[assaf.id, bob.id]]
        end        
      end
      describe "should find the right microposts" do
        it "with one search term" do
          Micropost.where(generate_search_microposts_sql('assaf')).should include(mp1)
          Micropost.where(generate_search_microposts_sql('assaf')).should_not include(mp2,mp3)
          Micropost.where(generate_search_microposts_sql('cling')).should include(mp2)
          Micropost.where(generate_search_microposts_sql('cling')).should_not include(mp1,mp3)
          Micropost.where(generate_search_microposts_sql('edu')).should include(mp3)
          Micropost.where(generate_search_microposts_sql('edu')).should_not include(mp1,mp2)
        end
      end
      it "work with two search terms" do
        Micropost.where(generate_search_microposts_sql('assaf cling')).should include(mp1,mp2)
        Micropost.where(generate_search_microposts_sql('assaf cling')).should_not include(mp3)
      end
    end
  end  

end