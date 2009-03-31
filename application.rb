require 'rubygems'
require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :authorization_realm, "Protected"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  include Merb::PaginationHelper

  def authorize(login, password)
    login == SiteConfig.admin_login && password == SiteConfig.admin_password
  end

  def authorization_realm
    "Protected"
  end
end

# root page
['/', '/page/:page'].each do |action|
  get action do 
    @pages, @entries = Entry.paginated(:order => [:published_at.desc], 
                                       :per_page => SiteConfig.per_page,
                                       :page => (params[:page] || 1).to_i)
    haml :main
  end
end

get '/feed' do
  content_type 'application/atom+xml', :charset => 'utf-8'
  @entries = Entry.all(:order => [:published_at.desc],
                       :limit => SiteConfig.per_page)
  builder :feed
end

post '/search' do
  @entries = Entry.search(:conditions => [params[:q].to_s], 
                          :limit => SiteConfig.per_page)
  haml :search
end

['/admin', '/admin/feeds'].each do |action|
  get action do
    login_required
    @feeds = Feed.all
    haml :admin
  end
end

post '/admin/feeds' do
  login_required
  @feed = Feed.new(:feed_url => params[:url])
  @feed.save
  redirect '/admin'
end

delete '/admin/feeds/:id' do
  login_required
  @feed = Feed.get(params[:id])
  @feed.destroy
  redirect '/admin'
end
