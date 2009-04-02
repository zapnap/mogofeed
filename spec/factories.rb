require 'factory_girl'

Factory.define :feed do |f|
  f.title     'zerosum dirt(nap) - Home'
  f.url       'http://blog.zerosum.org/'
  f.feed_url  'http://feeds2.feedburner.com/ZerosumDirtnap'
  f.created_at Time.now
  f.updated_at Time.now
  f.approved   true
end

Factory.define :entry do |f|
  f.title        'Blog Entry'
  f.url          'http://localhost:3000/blog-entry'
  f.author       'Cookie Monster'
  f.summary      'Mmmm cookies!'
  f.content      'Mmmm cookies! ' * 3
  f.published_at Time.now
  f.association  :feed
end
