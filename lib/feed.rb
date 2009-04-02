class Feed
  include DataMapper::Resource

  ATTR_MAP = {
               :title     => :title,
               :url       => :url,
               :feed_url  => :feed_url,
               :etag      => :etag
             }

  property :id,               Serial
  property :title,            String, :length => 255
  property :url,              String, :length => 255
  property :feed_url,         String, :length => 255
  property :etag,             String
  property :created_at,       Time
  property :updated_at,       Time
  property :approved,         Boolean, :default => false

  # will set feed attributes to remote feed values or fail validation if not found
  validates_with_method :feed_url, :method => :check_remote_feed

  validates_present    :url
  validates_is_unique  :url, :feed_url

  has n, :entries
  is_paginated

  before(:destroy) do
    self.entries.all.destroy!
  end

  # updates the feed attributes and cached feed entries, returns number of new entries
  def update_from_remote
    update_with_remote_feed
    save if dirty?
    update_with_remote_entries
  end
  
  # Approves the feed - meaning it will be shown in the main listing.
  def approve!
    self.approved = true
    self.save!
  end

  # returns the live remote feed, as provided by Feedzirra
  def remote_feed
    @feed ||= Feedzirra::Feed.fetch_and_parse(self.feed_url || '')
    @feed.is_a?(Fixnum) ? nil : @feed
  end
  
  # Returns an array of tuples, each being [title, url, [feed-previews]]
  # for a given url. Used for discovering feeds.
  def self.preview_url(feed_or_blog_url, recurse = true)
    @feed = Feedzirra::Feed.fetch_and_parse(feed_or_blog_url.to_s)
    if @feed
      [[@feed.title, feed_or_blog_url, @feed.entries.map { |e| [e.title, e.url] }]]
    elsif recurse
      urls = Columbus.new(feed_or_blog_url).all
      urls.map { |u| preview_url(u.url, false) }.reject { |u| u.empty? }.inject([]) { |a, c| a + c }
    else
      []
    end
  end

  private

  # autodiscover news feed from a url
  def discover_feed
    primary = Columbus.new(self.url).primary
    self.feed_url = primary.nil? ? self.url : primary.url
    true
  rescue
    false
  end

  # update feed attributes from remote feed
  def update_with_remote_feed
    ATTR_MAP.each { |k,v| self.send("#{v.to_s}=", remote_feed.send(k)) unless remote_feed.send(k).nil? } if remote_feed
  end

  # update cached feed entries from remote feed
  def update_with_remote_entries
    count = 0
    if remote_feed
      remote_feed.entries.each do |entry|
        if Entry.first(:url => entry.url)
          break # should be ordered most to least recent, so safe to disregard the rest
        else
          entry.sanitize!
          count += 1 if self.entries.create_from_feed(self, entry)
        end
      end
    end
    count
  end

  # validation to ensure that a feed_url contains a valid RSS or Atom feed
  def check_remote_feed
    if discover_feed && remote_feed
      update_with_remote_feed
      true
    else
      [false, "Feed url must contain a valid RSS or Atom feed"]
    end
  end
end
