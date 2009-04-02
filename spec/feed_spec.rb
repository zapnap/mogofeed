require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Feed' do
  before(:each) do
    Feed.all.destroy!
    Entry.all.destroy!
    @feed = Factory.build(:feed, :approved => false)
  end

  specify 'should be valid' do
    @feed.stub!(:check_remote_feed).and_return(true)
    @feed.should be_valid
  end

  specify 'should default to not approved' do
    @feed.should_not be_approved
  end
  
  specify 'should let you approve it' do
    @feed.stub!(:check_remote_feed).and_return(true)
    @feed.approve!
    @feed.should be_approved
  end

  context 'validations' do
    before(:each) do
      @feed.stub!(:check_remote_feed).and_return(true)
    end

    specify 'should require a url' do
      @feed.url = nil
      @feed.should_not be_valid
      @feed.errors[:url].should include("Url must not be blank")
    end

    specify 'should require a unique url' do
      @feed.save
      @feed = Factory.build(:feed)
      @feed.should_not be_valid
      @feed.errors[:url].should include("Url is already taken")
    end

    specify 'should require a unique feed url' do
      @feed.save
      @feed = Factory.build(:feed)
      @feed.should_not be_valid
      @feed.errors[:feed_url].should include("Feed url is already taken")
    end
  end

  specify 'should check feed url at creation time' do
    @feed.should_receive(:discover_feed).and_return(true)
    @feed.should_receive(:remote_feed).and_return(nil)
    @feed.feed_url = 'bad kitty'
    @feed.should_not be_valid
    @feed.errors[:feed_url].should include("Feed url must contain a valid RSS or Atom feed")
  end

  specify 'should auto-discover feed url from website at creation time' do
    @feed.feed_url = nil
    @feed.url = 'http://nhruby.org'
    @feed.save.should be_true
    @feed.feed_url.should == 'http://nhruby.org/feed/atom.xml'
  end

  specify 'should accept feed url directly in place of discovery url' do
    feed_url = @feed.feed_url
    @feed.url = feed_url
    @feed.save.should be_true
    @feed.feed_url.should == feed_url
    @feed.url.should_not == feed_url # home site url provided by feed
  end

  specify 'should retrieve remote feed attributes on create' do
    @feed.title = nil
    @feed.save.should be_true
    @feed.title.should_not be_nil # should be set to remote feed title
  end

  describe 'when updating' do
    before(:each) do
      @feed.stub!(:check_remote_feed).and_return(true)
      @feed.save
      @entry = Factory(:entry)
    end

    specify 'should retrieve remote data' do
      Feedzirra::Feed.should_receive(:fetch_and_parse).and_return(0)
      @feed.update_from_remote
    end

    specify 'should update feed attributes if changed' do
      @feed.update_from_remote
      @feed.title.should == 'zerosum dirt(nap) - Home'
    end

    specify 'should add new entries for this feed' do
      @feed.entries.should_receive(:create_from_feed).at_least(3).times.and_return(true)
      @feed.update_from_remote.should > 0
    end

    specify 'should not add new entries if they already exist' do
      @feed.remote_feed.should_receive(:entries).and_return([mock('Data', :url => @entry.url)])
      @feed.entries.should_not_receive(:create_from_feed)
      @feed.update_from_remote.should == 0
    end
  end
end
