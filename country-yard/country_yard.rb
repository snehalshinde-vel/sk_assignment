require "net/http"
require "nokogiri"
require "pathname"
require "json"

json_urls = File.read(Pathname("../urls.json"))
parse_json_urls= JSON.parse(json_urls)["courtyard"]

info = []


brand_obj= {}
brandName= ""
parse_json_urls.each do |url|
  puts url
  response = Net::HTTP.get_response(URI("https://www.marriott.com/en-us/hotels/#{url}/overview/"))

  if response.code != "200"
    puts "HTTP Error"
  end

  doc = Nokogiri::HTML(response.body)
  brandName = doc.css("h4.marriott-header-subnav__title-heading.pr-3.my-auto.t-subtitle-xl").text.strip.split(" ")[0][/^Courtyard/]
  puts brandName
  name  = doc.css("h4.marriott-header-subnav__title-heading.pr-3.my-auto.t-subtitle-xl").text.strip.split(" ")[1]
  puts name

  footer_div = doc.at_css("div.dynamic-footer__social-media")
  information_array = []
  footer_div.css("div.pb-2").each do |innerText|
      information_array << innerText.text.strip
  end

  puts information_array
  phoneNo = information_array[1].split("\n")[0].split("Toll Free:")[1]
  faxNo = information_array[1].split("Fax: ")[1]
  split_address= information_array[0].strip.split(", ")
  pinCode= split_address[-1]
  country = split_address[-2]
  puts split_address[-3]
  puts "hii"
  state = split_address[-3]
  city = split_address[-4]
  add= split_address[0, split_address.length-1].join(", ")
  puts pinCode, faxNo, phoneNo, add
  aTag = doc.css("div.marriott-header-subnav__menu__submenu.withImage.leftSide a")[0]
  lat, lang = aTag["href"].split("query=")[1].split(",")
  brand_info = {
      "name" => name,
      "phoneNo" => phoneNo,
      "faxNo"=>faxNo,
      "email" => "",
      "address" => add,
      "Pincode" => pinCode,
      "country" => country,
      "state"=>state,
      "city"=>city,
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
