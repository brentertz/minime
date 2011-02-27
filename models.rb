%w(dm-core dm-migrations dm-transactions dm-timestamps dm-types ./lib/base71 restclient xmlsimple).each {|lib| require lib}

class Link
  include DataMapper::Resource
  property  :id,          Serial
  property  :url,         Text
  property  :slug,        String
  property  :created_at,  DateTime
  has n, :visits

  def self.shorten(url, custom=nil)
    uri = URI::parse(url)
		raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS

    if custom
      raise 'This custom URL has already been used. Please try again.' unless Link.first(:slug => custom).nil?
      link = nil
      transaction do |txn|
        link = Link.create(:url => url, :slug => custom)
      end
      return link
    else
      link = Link.first(:url => url)
      if !link
        transaction do |txn|
          link = Link.create(:url => url)
          link.slug = Base71.to_s(link.id)
          link.save
        end
      end
      return link
    end
  end
end

class Visit
  include DataMapper::Resource
  property  :id,          Serial
  property  :ip,          IPAddress
  property  :country,     String
  property  :created_at,  DateTime
  belongs_to  :link

  after :create, :set_country

  def set_country
    xml = RestClient.get "http://api.hostip.info/get_xml.php?ip=#{ip}"
    self.country = XmlSimple.xml_in(xml.to_s, {'ForceArray' => false})['featureMember']['Hostip']['countryAbbrev']
    self.save
  end
end