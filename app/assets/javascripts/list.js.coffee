# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require jquery_ujs
#= require prefixfree
#= require add2home

class Compass
  constructor: (options = {enableHighAccuracy: yes, maximumAge: 10000, timeout: 100000}) ->
    if navigator.geolocation
      @_progress_to 33
      @navigatorID = navigator.geolocation.watchPosition(@_parseGPS, @_parseErr, options)
    else
      @_message 'Za delovanje potrebujem GPS'

  _progress_to: (percent) ->
    $('#nearest-progress').css width: "#{percent}%"

  _message: (text) ->
    $('#accordion').text(text)

  _parseGPS: (position) =>
    if position.coords.accuracy < 100
      @stop()
      @_progress_to 67
      $.get '/list/nearest', { lat: position.coords.latitude, lng: position.coords.longitude }, (data) ->
        $('#accordion').html(data)

  _parseErr: (err) =>
    switch err.code
      when 1
        error = 'Za delovanje potrebujem dostop do lokacije'
      when 2
        error = 'Ne morem pridobiti lokacije'
      when 3
        error = 'GPS se ne odziva'
      else
        error = 'Well, this is embarassing...'
    @_message error

  stop: ->
    navigator.geolocation.clearWatch @navigatorID

window.Compass = Compass
