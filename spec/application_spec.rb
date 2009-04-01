require "#{File.dirname(__FILE__)}/spec_helper"

describe 'Application' do
  include Rack::Test::Methods

  def app
    Sinatra::Application.new
  end

  before(:each) do
    Feed.all.destroy!
    Entry.all.destroy!
    @feed = Factory(:feed)
    @entry = Factory(:entry)
  end

  context 'home page' do
    specify "should show the default index page" do
      get '/'
      last_response.should be_ok
      last_response.body.should have_tag('h1', /#{SiteConfig.title}/)
    end

    specify 'should show the most recent entries' do
      get '/'
      last_response.should be_ok
      last_response.body.should have_tag("li#entry-#{@entry.id}", :count => 1)
    end

    specify 'should retrieve second page of results' do
      Entry.should_receive(:paginated).with(:order    => [:published_at.desc],
                                            :per_page => SiteConfig.per_page, 
                                            :page     => 2).and_return([3, [@entry]])
      get '/page/2'
    end
  end

  context 'atom feed' do
    specify 'should contain recent entries' do
      get '/feed'
      last_response.should be_ok
      last_response.body.should have_tag("entry", :count => 1) do |entry|
        entry.should have_tag("content", @entry.content)
      end
    end
  end

  context 'search queries' do
    before(:each) do
      Entry.stub!(:search).and_return([@entry])
    end

    specify 'should return matching records' do
      Entry.should_receive(:search).with(:conditions => ['power ring'], :limit => SiteConfig.per_page).and_return([@entry])
      post '/search', :q => 'power ring'
    end

    specify 'should render the search results' do
      post '/search', :q => 'power ring'
      last_response.should be_ok
      last_response.body.should have_tag("h2 span", /power ring/)
    end
  end

  context 'admin' do

    context 'listing feeds' do
      specify 'should include a list of known feeds' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        get '/admin'
        last_response.should be_ok
        last_response.body.should have_tag("li#feed-#{@feed.id}", :count => 1)
      end

      specify 'should include a form for adding a new feed' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        get '/admin'
        last_response.should be_ok
        last_response.body.should have_tag("form[@action='/admin/feeds']")
      end

      specify 'should require login' do
        get '/admin'
        last_response.status.should == 401
      end
    end

    context 'adding a new feed' do
      specify 'should create a new feed' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        lambda { 
          post '/admin/feeds', :url => 'http://www.nhruby.org'
        }.should change(Feed, :count).by(1)
      end

      specify 'should redirect to the main admin page' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        post '/admin/feeds', :url => 'http://www.nhruby.org'
        follow_redirect!
        last_request.url.should match(/.*\/admin$/)
      end

      specify 'should require login' do
        post '/admin/feeds', :url => 'http://www.nhruby.org'
        last_response.status.should == 401
      end
    end

    context 'deleting a feed' do
      specify 'should remove the feed' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        lambda { 
          delete "/admin/feeds/#{@feed.id}"
        }.should change(Feed, :count).by(-1)
      end

      specify 'should redirect to the main admin page' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        delete "/admin/feeds/#{@feed.id}"
        follow_redirect!
        last_request.url.should match(/.*\/admin$/)
      end

      specify 'should require login' do
        delete '/admin/feeds/1'
        last_response.status.should == 401
      end
    end

    context 'updating feeds' do
      specify 'should run update for the specified feed' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        Feed.should_receive(:get).with('1').and_return(@feed)
        @feed.should_receive(:update_from_remote).and_return(true)
        post "/admin/feeds/#{@feed.id}/update"
      end

      specify 'should redirect to the main admin page' do
        authorize SiteConfig.admin_login, SiteConfig.admin_password
        post "/admin/feeds/#{@feed.id}/update"
        follow_redirect!
        last_request.url.should match(/.*\/admin$/)
      end

      specify 'should require login' do
        post '/admin/feeds/1/update'
        last_response.status.should == 401
      end
    end
  end
end
