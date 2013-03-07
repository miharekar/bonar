//= require gmapsjs
//= require oms

jQuery ->
  successLocation = (position) ->
    map.setZoom 15
    currentLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
    map.panTo currentLocation
  
  errorLocation = (msg) ->    
    alert 'NAPAKA: Ne morem pridobiti lokacije'
  
  getMarkerIcon = (color) ->
    new google.maps.MarkerImage('http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|' + color, new google.maps.Size(21, 34), new google.maps.Point(0, 0), new google.maps.Point(10, 34))
  
  displayRestaurants = ->    
    i = 0
    while i < restaurants.length
      restaurant = restaurants[i]
      content = '<h4><a href="' + restaurant['link'] + '" target="_blank">' + restaurant['name'] + '</a></h4>'
      content += '<address>' + restaurant['address'] + '</address>'
      content += '<p>' + restaurant['price'] + '</p>'
      marker = map.addMarker
        lat: restaurant['coordinates'][0]
        lng: restaurant['coordinates'][1]
        title: restaurant['name']
        icon: scaleMarkers[restaurant['price'][0]]
        content: content
      oms.addMarker(marker);
      i++
      
  searchRestaurants = (search) ->
    $.post '/search',
      search: search
    , ((data) ->
      map.removeMarkers()
      if data.length
        window.restaurants = data
        displayRestaurants()
    ), 'json'
  
  map = new GMaps(
    div: '#map'
    lat: 46.119944
    lng: 14.815333
    zoom: 8
    disableDefaultUI: true
  )
  
  oms = new OverlappingMarkerSpiderfier(map.map,
    keepSpiderfied: true
    markersWontMove: true
    markersWontHide: true
  )
  
  scaleMarkers = [getMarkerIcon('ffe7c8'), getMarkerIcon('ffcc95'), getMarkerIcon('ffad60'), getMarkerIcon('ff8c1f'), getMarkerIcon('e04f00')]
  searchRestaurants ''
  
  iw = new google.maps.InfoWindow()
  oms.addListener 'click', (marker) ->
    iw.setContent marker.content
    iw.open map.map, marker
  
  if navigator.geolocation
    navigator.geolocation.getCurrentPosition successLocation, errorLocation,
      enableHighAccuracy: true
      maximumAge: 10000
    GeoMarker = new GeolocationMarker map.map
  else
    alert 'Geolocation is not supported.'
  
  timer = null
  $('#restaurantSearch').on 'keyup', ->
    clearTimeout timer
    search = $(this).val()
    timer = setTimeout(->
        searchRestaurants search
      , 500)