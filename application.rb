require 'rubygems'
require 'sinatra'
require 'environment'

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  include Merb::PaginationHelper
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
  @entries = Entry.search(:conditions => [params[:q].to_s])
  haml :search
end
