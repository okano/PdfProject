require 'mime/types'

xml.instruct! :xml, version: "1.0" 
xml.feed('xmlns:dc' => "http://purl.org/dc/terms/", 'xmlns:opds' => "http://opds-spec.org/2010/catalog", 'xmlns' => "http://www.w3.org/2005/Atom") do
  xml.title "calibre ライブラリ"
  xml.author do
    xml.name "calibre"
    xml.uri "http://calibre-ebook.com"
  end
  xml.id "calibre-all:timestamp"
  xml.updated @updated
  xml.link(href: "/opds/search/{searchTerms}", type: "application/atom+xml", rel: "search", title: "Search")
  xml.link(href: "/opds", type: "application/atom+xml;type=feed;profile=opds-catalog", rel: "start")
  xml.link(href: "/opds", type: "application/atom+xml;type=feed;profile=opds-catalog", rel: "up")
  xml.link(href: "/opds/navcatalog/4f6e6577657374", type: "application/atom+xml;type=feed;profile=opds-catalog", rel: "first")
  xml.link(href: "/opds/navcatalog/4f6e6577657374?offset=0", type: "application/atom+xml;type=feed;profile=opds-catalog", rel: "last")
  
  @contents.each do |content|
    xml.entry do
      xml.title content.title
      xml.author do
        xml.name content.author
      end
      xml.id "urn:uuid:#{content.uuid}"
      xml.contentid_in_server content.content_id
      xml.updated content.updated_at.to_datetime.iso8601
      xml.content(type: 'xhtml') do
        xml.div(xmlns: 'http://www.w3.org/1999/xhtml') do
          xml.p content.description
        end
      end
      xml.link(href: content.file_url, type: content.file_url.end_with?('zip') ? 'application/zip' : 'application/x-cbz', rel: 'http://opds-spec.org/acquisition') if content.file?
      xml.link(href: content.image_url, type: MIME::Types.type_for(content.image_url)[0], rel: 'http://opds-spec.org/image/cover')
      xml.link(href: content.image_url(:thumb), type: MIME::Types.type_for(content.image_url)[0], rel: 'http://opds-spec.org/image/thumbnail') 
    end
  end
end
