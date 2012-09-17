# courtesy of https://github.com/cesarsalazar

require 'json'
require 'net/http'
require 'uri'

#Example Data
municipality = "Concepcion Papalo"
state = "Oaxaca"
country = "Mexico"

#Perform a GET request to the Google Maps API for each municipality specifying also the state
url = URI.parse('http://maps.google.com/maps/api/geocode/json?sensor=false&address='+URI.escape(municipality+","+state+","+country))

#Results come in JSON format, so we convert them in a hash in order to retrieve the data
response = JSON.parse(Net::HTTP.get(url).force_encoding('UTF-8'))
results = response['results']  
foo = results[0]
geometry = foo['geometry']
location = geometry['location']  

#Finally LAT and LONG as strings
lat = location['lat'].to_s
long = location['lng'].to_s

puts lat, long
