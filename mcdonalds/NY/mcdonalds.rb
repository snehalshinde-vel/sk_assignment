require "http"
require "json"


get_multiple_locs = File.read(Pathname("../urls.json"))
parse_json_loc= JSON.parse(get_multiple_locs)["loc"]




def get_api_data(name, response)
  aFile = File.new("./data/api_response_#{name}.json", "w+")
  if aFile
    aFile.write(response)
  end
end


parse_json_loc.each do |loc|
  puts loc
  url = "https://www.mcdonalds.com/googleappsv2/geolocation?latitude=#{loc["lat"]}&longitude=#{loc["lang"]}&radius=#{loc["radius"]}&maxResults=#{loc["results"]}&country=#{loc["country"]}&language=#{loc["language"]}"
  response  = HTTP.get(url)
  if response.code != 200
    puts "Http:Error"
    exit 1
  end
  parse_json= JSON.parse(response)
  informations ={}
  main_city  = ""
  parse_json["features"].each do |location|
    lat, lang = location["geometry"]["coordinates"]
    address = "#{location["properties"]["addressLine1"].strip},\
              #{location["properties"]["addressLine3"].strip},\
              #{location["properties"]["subDivision"].strip},\
              #{location["properties"]["addressLine4"].strip},\
              #{location["properties"]["postcode"]}".gsub(/\s+/, ' ')
    telephone= location["properties"]["telephone"]
    isOpen = location["properties"]["openstatus"]
    timeZone = location["properties"]["timeZone"]
    name = location["properties"]["shortDescription"]
    pinCode = location["properties"]["postcode"]
    main_city = location["properties"]["addressLine3"].strip
    location_obj = {
      name: name,
      lat: lat,
      lang: lang,
      address: address,
      pinCode:pinCode,
      telephone: telephone,
      isOpen: isOpen,
      timeZone: timeZone,
    }
    informations[main_city] ||= []
    informations[main_city] << location_obj
  end
  get_api_data(main_city, response) if main_city
  extract_file = File.new("./data/extract_info.json", "w+")
  if extract_file
    extract_file.write(JSON.generate(informations))
  end
end
puts "information successful scrap: 200"
