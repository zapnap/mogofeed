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
                 :search          => false                     # disabled by default
               )

  if SiteConfig.search
    # change me if you're enabling search functionality
    # tested with MySQL - fill in username, password, database name
    DataMapper.setup(:default, "mysql://root@localhost/mogo")
    DataMapper.setup(:search, "sphinx://localhost:3312")
  else
    # otherwise we use a standard sqlite3 database named after the current environment
    DataMapper.setup(:default, "sqlite3:///#{File.expand_path(File.dirname(__FILE__))}/#{Sinatra::Base.environment}.db")
  end

  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end

# prevent Object#id warnings
Object.send(:undef_method, :id)
