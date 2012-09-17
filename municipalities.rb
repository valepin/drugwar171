# some code contained courtesy of https://github.com/cesarsalazar

require 'csv'
require 'json'
require 'net/http'
require 'uri'

#global
country = "Mexico"

CSV.open("data/latlon.csv", "wb") do |csv|
  CSV.foreach("data/stateandmuni.csv") do |row|
    parsed = row[0].split(/\t/)
    state = parsed[0]
    municipality = parsed[1]
  
    #Perform a GET request to the Google Maps API for each municipality specifying also the state
    url = URI.parse('http://maps.google.com/maps/api/geocode/json?sensor=false&address='+URI.escape(municipality+","+state+","+country))

    #Results come in JSON format, so we convert them in a hash in order to retrieve the data
    response = JSON.parse(Net::HTTP.get(url).force_encoding('UTF-8'))
    results = response['results']  
    foo = results[0]
    
    if foo.nil?
      lat = 'NA'
      lon = 'NA'
    else
      geometry = foo['geometry']
      location = geometry['location']  
  
      #Finally LAT and LONG as strings
      lat = location['lat'].to_s
      long = location['lng'].to_s
    end
    csv << [state,municipality,lat,long]
  end
end

