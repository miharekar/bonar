//= require gmapsjs
//= require oms
//= require geolocationmarker

$ ->
  latestSearch = null
  timer = null
  allRestaurants = null
  GeoMarker = null
  
  getMarkerIcon = (color) ->
    new google.maps.MarkerImage('http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|' + color, new google.maps.Size(21, 34), new google.maps.Point(0, 0), new google.maps.Point(10, 34))
  
  displayRestaurants = ->
    map.removeMarkers()
    i = 0
    while i < restaurants.length
      restaurant = restaurants[i]
      marker = map.addMarker
        lat: restaurant['coordinates'][0]
        lng: restaurant['coordinates'][1]
        icon: scaleMarkers[restaurant['price'][0]]
        content: restaurant['content']
      oms.addMarker(marker);
      i++
      
    if restaurants.length == 1 or (restaurants.length == 2 and restaurants[0]['coordinates'][0] == restaurants[1]['coordinates'][0] and restaurants[0]['coordinates'][1] == restaurants[1]['coordinates'][1])
      map.setZoom 15
      map.panTo marker.position
      google.maps.event.trigger(marker, 'click')
      
  searchForRestaurants = (search) ->
    if latestSearch isnt search
      latestSearch = search
      if search == '' and allRestaurants?        
        window.restaurants = allRestaurants
        displayRestaurants()
      else
        $.post '/search',
          search: search
        , ((data) ->
          window.restaurants = data
          displayRestaurants()
          if search == ''
            allRestaurants = data
        ), 'json'

  showGeoMarker = ->
    GeoMarker = new GeolocationMarker map.map
    GeoMarker.setMinimumAccuracy 100
    google.maps.event.addListenerOnce GeoMarker, 'position_changed', ->
      map.setZoom 15
      map.panTo @getPosition()
      $('#geolocateIcon').show()
  
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
  
  iw = new google.maps.InfoWindow()
  oms.addListener 'click', (marker) ->
    iw.setContent marker.content
    iw.open map.map, marker
  
  scaleMarkers = [getMarkerIcon('ffe7c8'), getMarkerIcon('ffcc95'), getMarkerIcon('ffad60'), getMarkerIcon('ff8c1f'), getMarkerIcon('e04f00')]
  searchForRestaurants ''

  if navigator.geolocation
    showGeoMarker()
    
  $('#geolocateIcon').on 'click', (event) ->
    event.preventDefault()
    map.panTo GeoMarker.getPosition()
  
  $('#restaurantSearch').on 'keyup', ->
    clearTimeout timer
    search = $(this).val()
    timer = setTimeout(->
        searchForRestaurants search
      , 500)