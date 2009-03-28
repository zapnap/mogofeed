class Entry
  include DataMapper::Resource

  ATTR_MAP = {
               :title      => :title,
               :url        => :url,
               :author     => :author,
               :summary    => :summary,
               :content    => :content,
               :categories => :categories,
               :published  => :published_at
             }

  property :id,           Serial
  property :feed_id,      Integer
  property :title,        String, :length => 255
  property :url,          String, :length => 255
  property :author,       String, :length => 255
  property :summary,      Text
  property :content,      Text
  property :categories,   String, :length => 255
  property :published_at, Time
  property :created_at,   Time
  property :updated_at,   Time

  validates_present    :title, :url, :content, :feed_id
  validates_is_unique  :url

  belongs_to :feed
  is :searchable
  is_paginated

  # create a new record directly from feed data
  def self.create_from_feed(feed, data)
    s = self.new(:feed => feed)
    ATTR_MAP.each { |k,v| s.send("#{v.to_s}=", data.send(k)) }
    #puts s.errors.full_messages.to_s unless s.valid?
    s.save && s
  end
end
