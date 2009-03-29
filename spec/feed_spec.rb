require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Feed' do
  before(:each) do
    Feed.all.destroy!
    Entry.all.destroy!
    @feed = Factory.build(:feed)
  end

  specify 'should be valid' do
    @feed.should be_valid
  end

  context 'validations' do
    before(:each) do
      @feed.stub!(:check_remote_feed).and_return(true)
    end

    #specify 'should require a title' do
    #  @feed.title = nil
    #  @feed.should_not be_valid
    #  @feed.errors[:title].should include("Title must not be blank")
    #end

    specify 'should require a feed url' do
      @feed.feed_url = nil
      @feed.should_not be_valid
      @feed.errors[:feed_url].should include("Feed url must not be blank")
    end

    specify 'should require a unique url' do
      @feed.save
      @feed = Factory.build(:feed)
      @feed.should_not be_valid
      @feed.errors[:feed_url].should include("Feed url is already taken")
    end
  end

  specify 'should check feed url' do
    @feed.stub!(:remote_feed).and_return(nil)
    @feed.feed_url = 'bad kitty'
    @feed.should_not be_valid
    @feed.errors[:feed_url].should include("Feed url must contain a valid RSS or Atom feed")
  end

  specify 'should retrieve remote feed attributes on create' do
    @feed.title = nil
    @feed.save
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
