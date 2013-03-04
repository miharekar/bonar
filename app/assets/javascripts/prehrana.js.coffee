//= require gmapsjs

jQuery ->
  successLocation = (position) ->
    map.setZoom 15
    currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
    map.panTo currentLocation
  
  errorLocation = (msg) ->    
    alert 'Error: ' + msg
  
  getMarkerIcon = (color) ->
    new google.maps.MarkerImage('http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|' + color, new google.maps.Size(21, 34), new google.maps.Point(0, 0), new google.maps.Point(10, 34))
  
  displayRestaurants = ->    
    i = 0
    bounds = new google.maps.LatLngBounds() 
    while i < restaurants.length
      restaurant = restaurants[i]
      content = '<h4>' + restaurant['name'] + '</h4>'
      content += '<address>' + restaurant['address'] + '</address>'
      content += '<p>' + restaurant['price'] + '</p>'
      marker = map.addMarker
        lat: restaurant['coordinates'][0]
        lng: restaurant['coordinates'][1]
        title: restaurant['name']
        icon: scaleMarkers[restaurant['price'][0]]
        infoWindow:
          content: content
      bounds.extend marker.getPosition()
      i++
    map.fitBounds bounds
  
  map = new GMaps(
    div: '#map'
    lat: 46.119944
    lng: 14.815333
    zoom: 8
    disableDefaultUI: true
  )
  
  scaleMarkers = [getMarkerIcon('ffe7c8'), getMarkerIcon('ffcc95'), getMarkerIcon('ffad60'), getMarkerIcon('ff8c1f'), getMarkerIcon('e04f00')]
  displayRestaurants()
  
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition successLocation, errorLocation,
      enableHighAccuracy: true
      maximumAge: 10000
    GeoMarker = new GeolocationMarker map.map
  else
    alert 'Geolocation is not supported.'
  
  $('#restaurantSearch').on 'keyup', ->
    if $(this).val().length != 1
      $.post "/search",
        search: $(this).val()
      , ((data) ->
        map.removeMarkers()
        if data.length
          window.restaurants = data
          displayRestaurants()
      ), "json"