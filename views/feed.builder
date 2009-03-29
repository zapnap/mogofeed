xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  xml.title SiteConfig.title
  xml.id SiteConfig.url_base
  xml.updated @entries.first.created_at.to_s unless @entries.empty?
  xml.author { xml.name SiteConfig.title }
 
  @entries.each do |entry|
    xml.entry do
      xml.title entry.title
      xml.link "rel" => "alternate", "href" => entry.url
      xml.id entry.url
      xml.published entry.published_at.to_s
      xml.updated entry.published_at.to_s
      xml.author { xml.name entry.author }
      xml.summary entry.summary, "type" => "html"
      xml.content entry.content, "type" => "html"
    end
  end
end
