# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#= require jquery_ujs
#= require prefixfree

class Compass
  constructor: (options = {enableHighAccuracy: yes, maximumAge: 10000, timeout: 100000}) ->
    @lat    = 0
    @lng    = 0
    @alt    = 0
    @acc    = 0
    @altAcc = 0
    @hdg    = 0
    @spd    = 0
    @_grabGPS(options)
  _grabGPS: (options) ->
    navigator.geolocation.watchPosition(@_parseGPS, @_parseErr, options)
  _parseGPS: (position) =>
    $.get 'nearest', position, (data) ->
      console.log data
  _parseErr: (err) ->
    switch err.code
      when 1
        @error = 'Permission denied by user'
      when 2
        @error = 'Cant fix GPS position'
      when 3
        @error = 'GPS is taking too long to respond'
      else
        @error = 'Well, this is embarassing...'
    #console.log @error
  stop: ->
    navigator.geolocation.clearWatch _grabGPS

window.Compass = Compass