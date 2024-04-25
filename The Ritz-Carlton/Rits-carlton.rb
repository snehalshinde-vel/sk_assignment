require "net/http"
require "nokogiri"
require "pathname"
require "json"

json_urls = File.read(Pathname("../urls.json"))
parse_json_urls= JSON.parse(json_urls)["the-ritz-carlton"]


info = []

brandName= ""
brand_obj= {}
parse_json_urls.each do |url|
  response = Net::HTTP.get_response(URI("https://www.ritzcarlton.com/en/hotels/#{url}/overview/"))

  if response.code != "200"
    puts "HTTP Error"
  end

  doc = Nokogiri::HTML(response.body)
  puts doc.css("h2.marriott-header-mobile-title.t-brand-font-m")
  brandName = doc.css("h2.marriott-header-mobile-title.t-brand-font-m").text.strip.split(", ")[0][/^The Ritz-Carlton/]
  puts brandName
  name  = doc.css("h2.marriott-header-mobile-title.t-brand-font-m").text.strip.split(", ")[1]
  puts name

  address = doc.css("div.dynamic-footer__social-media p.t-brand-font-m")
  split_add=[]
  address.each do |add|
    if add.text.include?("Fax:")
      puts "test: #{add.text}"
      fax_number = add.text.split("Fax: ")[1].strip
      split_add<< fax_number
    else
      split_add<<add.text.strip
    end
  end
  phoneNo = split_add[2]
  split_add.pop
  puts "split_add: #{split_add}"

  aTag = doc.css("div.marriott-header-subnav__menu__submenu.withImage.leftSide a")[0]
  lat, lang = aTag["href"].split("query=")[1].split(",")
  brand_info = {
      "name" => name,
      "phoneNo" => phoneNo,
      "address" => split_add.join(", ").strip,
      "Pincode" => split_add[1].split(",")[3].strip,
      "country" => split_add[1].split(", ")[2].strip,
      "email" => "",
      "location" => [lat, lang]
    }
  puts brand_info
  if brand_obj.include?(brandName)
    brand_obj[brandName]<<brand_info
  else
    brand_obj[brandName]= [brand_info]
  end
  puts info
  afile = File.new(Pathname("./html/#{name}.html"), "w+")
  afile.write(doc)
end
info<<brand_obj
extract_data = File.new(Pathname("./data/#{brandName}.json"), "a+")
extract_data.write(JSON.generate(info))
