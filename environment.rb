require 'rubygems'
require 'dm-core'
require 'dm-validations'
require 'dm-aggregates'
require 'dm-is-searchable'
require 'dm-sphinx-adapter'
require 'dm-timestamps'
require 'dm-is-paginated'
require 'merb-pagination'
require 'haml'
require 'ostruct'
require 'feedzirra'

require 'sinatra' unless defined?(Sinatra)

configure do
  SiteConfig = OpenStruct.new(
                 :title           => 'Planet Mogo',            # title of application
                 :url_base        => 'http://localhost:4567/', # base URL for your site
                 :per_page        => 10,                       # number of entries to display per page
                 :search          => 'sphinx://localhost:3312' # set to false to disable searching
               )

  #DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db")
  DataMapper.setup(:default, "mysql://root@localhost/mogo")
  DataMapper.setup(:search, SiteConfig.search) if SiteConfig.search

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end

# prevent Object#id warnings
Object.send(:undef_method, :id)
