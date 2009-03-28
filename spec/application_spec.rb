require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Application' do
  include Sinatra::Test

  before(:each) do
    @entry = Factory(:entry)
  end

  context 'home page' do
    specify "should show the default index page" do
      get '/'
      @response.should be_ok
      @response.body.should match(/#{SiteConfig.title}/)
    end

    specify 'should show the most recent entries' do
      get '/'
      @response.should be_ok
      @response.should have_tag("li#entry-#{@entry.id}", :count => 1)
    end

    specify 'should retrieve second page of results' do
      Entry.should_receive(:paginated).with(:order    => [:published_at.desc],
                                            :per_page => SiteConfig.per_page, 
                                            :page     => 2).and_return([3, [@entry]])
      get '/page/2'
    end
  end

  context 'search queries' do
    before(:each) do
      Entry.stub!(:search).and_return([@entry])
    end

    specify 'should return matching records' do
      Entry.should_receive(:search).with({:content => 'power ring'}).and_return([@entry])
      post '/search', :q => 'power ring'
    end

    specify 'should render the search results' do
      post '/search', :q => 'power ring'
      @response.should be_ok
      @response.should have_tag("h1 span", /power ring/)
    end
  end
end
