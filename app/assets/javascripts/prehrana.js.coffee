//= require gmapsjs

jQuery ->
  successLocation = (position) ->
    map.setZoom 15
    currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
    map.panTo currentLocation
  
  errorLocation = (msg) ->    
    alert "Error: " + msg
  
  getMarkerIcon = (color) ->
    new google.maps.MarkerImage("http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|" + color, new google.maps.Size(21, 34), new google.maps.Point(0, 0), new google.maps.Point(10, 34))
  
  loadRestaurants = (map) ->
    scaleMakers = [getMarkerIcon("ffe7c8"), getMarkerIcon("ffcc95"), getMarkerIcon("ffad60"), getMarkerIcon("ff8c1f"), getMarkerIcon("e04f00")]
    i = 0
    while i < restaurants.length
      restaurant = restaurants[i]
      content = "<h4>" + restaurant["name"] + "</h4>"
      content += "<address>" + restaurant["address"] + "</address>"
      content += "<p>" + restaurant["price"] + "</p>"
      map.addMarker
        lat: restaurant["coordinates"][0]
        lng: restaurant["coordinates"][1]
        title: restaurant["name"]
        icon: scaleMakers[restaurant["price"][0]]
        infoWindow:
          content: content
      i++
  
  map = new GMaps(
    div: "#map"
    lat: 46.119944
    lng: 14.815333
    zoom: 8
    disableDefaultUI: true
  )
  
  loadRestaurants map
  
  if navigator.geolocation
   navigator.geolocation.getCurrentPosition successLocation, errorLocation, {enableHighAccuracy:true, maximumAge:10000}
   GeoMarker = new GeolocationMarker map.map
  else
   alert "Geolocation is not supported."