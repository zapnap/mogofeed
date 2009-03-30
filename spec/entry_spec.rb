require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Entry' do
  before(:each) do
    Entry.all.destroy!
    @entry = Factory.build(:entry)
    @feed = Factory(:feed)
  end

  specify 'should be valid' do
    @entry.should be_valid
  end

  context 'validations' do
    specify 'should require a title' do
      @entry.title = nil
      @entry.should_not be_valid
      @entry.errors[:title].should include("Title must not be blank")
    end

    specify 'should require a url' do
      @entry.url = nil
      @entry.should_not be_valid
      @entry.errors[:url].should include("Url must not be blank")
    end

    specify 'should require a feed' do
      @entry.feed_id = nil
      @entry.should_not be_valid
      @entry.errors[:feed_id].should include("Feed must not be blank")
    end

    specify 'should require a summary' do
      @entry.summary = nil
      @entry.should_not be_valid
      @entry.errors[:summary].should include("Summary must not be blank")
    end

    specify 'should require a unique url' do
      @entry.save
      @entry = Factory.build(:entry)
      @entry.should_not be_valid
      @entry.errors[:url].should include("Url is already taken")
    end
  end

  specify 'should create new entry from feed data' do
    lambda do
      Entry.create_from_feed(@feed, entry_data)
    end.should change(Entry, :count)
  end

  specify 'should map attributes from feed data' do
    Entry.create_from_feed(@feed, entry_data)
    Entry.first.title.should == 'Hulk Smash!'
  end

  def entry_data
    OpenStruct.new(
      :title         => 'Hulk Smash!',
      :url           => 'http://foo.bar/hulk-smash',
      :author        => 'Stan',
      :summary       => 'Wreck up the place',
      :content       => 'Wreck up the place',
      :last_modified => Time.now
    )
  end
end
