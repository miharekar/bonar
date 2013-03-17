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
      content = '<div class="prehrana_info"><h4><a href="' + restaurant['link'] + '0" target="_blank">' + restaurant['name'] + '</a></h4>'
      content += '<address>' + restaurant['address'] + '</address>'
      content += '<p><strong>' + restaurant['price'] + '</strong></p>'
      content += '<ul>'
      content += '<li>Teden: ' + restaurant['opening']['Week'][0] + ' - ' + restaurant['opening']['Week'][1] + '</li>'
      if restaurant['opening']['Saturday']
        content += '<li>Sobota: ' + restaurant['opening']['Saturday'][0] + ' - ' + restaurant['opening']['Saturday'][1] + '</li>'
      else
        content += '<li>Sobota: zaprto</li>'
      if restaurant['opening']['Sunday']
        content += '<li>Nedelja: ' + restaurant['opening']['Sunday'][0] + ' - ' + restaurant['opening']['Sunday'][1] + '</li>'
      else
        content += '<li>Nedelja: zaprto</li>'
      if restaurant['opening']['Notes']
        content += '<li>Opombe: ' + restaurant['opening']['Notes'] + '</li>'
      content += '</ul></div>'
      marker = map.addMarker
        lat: restaurant['coordinates'][0]
        lng: restaurant['coordinates'][1]
        title: restaurant['name']
        icon: scaleMarkers[restaurant['price'][0]]
        content: content
      oms.addMarker(marker);
      i++
      
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