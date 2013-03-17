/*!
 * GMaps.js v0.2.30
 * http://hpneo.github.com/gmaps/
 *
 * Copyright 2012, Gustavo Leon
 * Released under the MIT License.
 */


if(window.google && window.google.maps){

  var GMaps = (function(global) {
    "use strict";

    var doc = document;
    var getElementById = function(id, context) {
      var ele
      if('jQuery' in global && context){
        ele = $("#"+id.replace('#', ''), context)[0]
      }else{
        ele = doc.getElementById(id.replace('#', ''));
      };
      return ele;
    };

    var GMaps = function(options) {
      var self = this;
      var events_that_hide_context_menu = ['bounds_changed', 'center_changed', 'click', 'dblclick', 'drag', 'dragend', 'dragstart', 'idle', 'maptypeid_changed', 'projection_changed', 'resize', 'tilesloaded', 'zoom_changed'];
      var events_that_doesnt_hide_context_menu = ['mousemove', 'mouseout', 'mouseover'];

      window.context_menu = {};

      if (typeof(options.el) === 'string' || typeof(options.div) === 'string') {
        this.el = getElementById(options.el || options.div, options.context);
      } else {
        this.el = options.el || options.div;
      };
      this.el.style.width = options.width || this.el.scrollWidth || this.el.offsetWidth;
      this.el.style.height = options.height || this.el.scrollHeight || this.el.offsetHeight;

      this.controls = [];
      this.overlays = [];
      this.layers = []; // array with kml and ft layers, can be as many
      this.singleLayers = {}; // object with the other layers, only one per layer
      this.markers = [];
      this.polylines = [];
      this.routes = [];
      this.polygons = [];
      this.infoWindow = null;
      this.overlay_el = null;
      this.zoom = options.zoom || 15;

      var markerClusterer = options.markerClusterer;

      //'Hybrid', 'Roadmap', 'Satellite' or 'Terrain'
      var mapType;

      if (options.mapType) {
        mapType = google.maps.MapTypeId[options.mapType.toUpperCase()];
      }
      else {
        mapType = google.maps.MapTypeId.ROADMAP;
      }

      var map_center = new google.maps.LatLng(options.lat, options.lng);

      delete options.el;
      delete options.lat;
      delete options.lng;
      delete options.mapType;
      delete options.width;
      delete options.height;
      delete options.markerClusterer;

      var zoomControlOpt = options.zoomControlOpt || {
        style: 'DEFAULT',
        position: 'TOP_LEFT'
      };

      var zoomControl = options.zoomControl || true,
          zoomControlStyle = zoomControlOpt.style || 'DEFAULT',
          zoomControlPosition = zoomControlOpt.position || 'TOP_LEFT',
          panControl = options.panControl || true,
          mapTypeControl = options.mapTypeControl || true,
          scaleControl = options.scaleControl || true,
          streetViewControl = options.streetViewControl || true,
          overviewMapControl = overviewMapControl || true;

      var map_options = {};

      var map_base_options = {
        zoom: this.zoom,
        center: map_center,
        mapTypeId: mapType
      };

      var map_controls_options = {
        panControl: panControl,
        zoomControl: zoomControl,
        zoomControlOptions: {
          style: google.maps.ZoomControlStyle[zoomControlStyle], // DEFAULT LARGE SMALL
          position: google.maps.ControlPosition[zoomControlPosition]
        },
        mapTypeControl: mapTypeControl,
        scaleControl: scaleControl,
        streetViewControl: streetViewControl,
        overviewMapControl: overviewMapControl
      }

      if(options.disableDefaultUI != true)
        map_base_options = extend_object(map_base_options, map_controls_options);

      map_options = extend_object(map_base_options, options);

      for(var i = 0; i < events_that_hide_context_menu.length; i++) {
        delete map_options[events_that_hide_context_menu[i]];
      }

      for(var i = 0; i < events_that_doesnt_hide_context_menu.length; i++) {
        delete map_options[events_that_doesnt_hide_context_menu[i]];
      }

      this.map = new google.maps.Map(this.el, map_options);

      if(markerClusterer) {
        this.markerClusterer = markerClusterer.apply(this, [this.map]);
      }

      // Context menus
      var buildContextMenuHTML = function(control, e) {
        var html = '';
        var options = window.context_menu[control];
        for (var i in options){
          if (options.hasOwnProperty(i)){
            var option = options[i];
            html += '<li><a id="' + control + '_' + i + '" href="#">' +
              option.title + '</a></li>';
          }
        }

        if(!getElementById('gmaps_context_menu')) return;
          
        var context_menu_element = getElementById('gmaps_context_menu');
        context_menu_element.innerHTML = html;

        var context_menu_items = context_menu_element.getElementsByTagName('a');

        var context_menu_items_count = context_menu_items.length;

        for(var i = 0; i < context_menu_items_count; i++){
          var context_menu_item = context_menu_items[i];

          var assign_menu_item_action = function(ev){
            ev.preventDefault();

            options[this.id.replace(control + '_', '')].action.apply(self, [e]);
            self.hideContextMenu();
          };

          google.maps.event.clearListeners(context_menu_item, 'click');
          google.maps.event.addDomListenerOnce(context_menu_item, 'click', assign_menu_item_action, false);
        }

        var left = self.el.offsetLeft + e.pixel.x - 15;
        var top = self.el.offsetTop + e.pixel.y - 15;

        context_menu_element.style.left = left + "px";
        context_menu_element.style.top = top + "px";

        context_menu_element.style.display = 'block';
      };

      var buildContextMenu = function(control, e) {
        if (control === 'marker') {
          e.pixel = {};
          var overlay = new google.maps.OverlayView();
          overlay.setMap(self.map);
          overlay.draw = function() {
            var projection = overlay.getProjection();
            var position = e.marker.getPosition();
            e.pixel = projection.fromLatLngToContainerPixel(position);

            buildContextMenuHTML(control, e);
          };
        }
        else {
          buildContextMenuHTML(control, e);
        }
      };

      this.setContextMenu = function(options) {
        window.context_menu[options.control] = {};

        for (var i in options.options){
          if (options.options.hasOwnProperty(i)){
            var option = options.options[i];
            window.context_menu[options.control][option.name] = {
              title: option.title,
              action: option.action
            };
          }
        }

        var ul = doc.createElement('ul');
        
        ul.id = 'gmaps_context_menu';
        ul.style.display = 'none';
        ul.style.position = 'absolute';
        ul.style.minWidth = '100px';
        ul.style.background = 'white';
        ul.style.listStyle = 'none';
        ul.style.padding = '8px';
        ul.style.boxShadow = '2px 2px 6px #ccc';

        doc.body.appendChild(ul);

        var context_menu_element = getElementById('gmaps_context_menu');

        google.maps.event.addDomListener(context_menu_element, 'mouseout', function(ev) {
          if(!ev.relatedTarget || !this.contains(ev.relatedTarget)){
            window.setTimeout(function(){
              context_menu_element.style.display = 'none';
            }, 400);
          }
        }, false);
      };

      this.hideContextMenu = function() {
        var context_menu_element = getElementById('gmaps_context_menu');
        if(context_menu_element)
          context_menu_element.style.display = 'none';
      };

      //Events

      var setupListener = function(object, name) {
        google.maps.event.addListener(object, name, function(e){
          if(e == undefined) {
            e = this;
          }

          options[name].apply(this, [e]);

          self.hideContextMenu();
        });
      }

      for (var ev = 0; ev < events_that_hide_context_menu.length; ev++) {
        var name = events_that_hide_context_menu[ev];

        if (name in options) {
          setupListener(this.map, name);
        }
      }

      for (var ev = 0; ev < events_that_doesnt_hide_context_menu.length; ev++) {
        var name = events_that_doesnt_hide_context_menu[ev];

        if (name in options) {
          setupListener(this.map, name);
        }
      }

      google.maps.event.addListener(this.map, 'rightclick', function(e) {
        if (options.rightclick) {
          options.rightclick.apply(this, [e]);
        }

        if(window.context_menu['map'] != undefined) {
          buildContextMenu('map', e);
        }
      });

      this.refresh = function() {
        google.maps.event.trigger(this.map, 'resize');
      };

      this.fitZoom = function() {
        var latLngs = [];
        var markers_length = this.markers.length;

        for(var i=0; i < markers_length; i++) {
          latLngs.push(this.markers[i].getPosition());
        }

        this.fitLatLngBounds(latLngs);
      };

      this.fitLatLngBounds = function(latLngs) {
        var total = latLngs.length;
        var bounds = new google.maps.LatLngBounds();

        for(var i=0; i < total; i++) {
          bounds.extend(latLngs[i]);
        }

        this.map.fitBounds(bounds);
      };

      // Map methods
      this.setCenter = function(lat, lng, callback) {
        this.map.panTo(new google.maps.LatLng(lat, lng));
        if (callback) {
          callback();
        }
      };

      this.getElement = function() {
        return this.el;
      };

      this.zoomIn = function(value) {
        this.zoom = this.map.getZoom() + value;
        this.map.setZoom(this.zoom);
      };

      this.zoomOut = function(value) {
        this.zoom = this.map.getZoom() - value;
        this.map.setZoom(this.zoom);
      };

      var native_methods = [];

      for(var method in this.map){
        if(typeof(this.map[method]) == 'function' && !this[method]){
          native_methods.push(method);
        }
      }

      for(var i=0; i < native_methods.length; i++){
        (function(gmaps, scope, method_name) {
          gmaps[method_name] = function(){
            return scope[method_name].apply(scope, arguments);
          };
        })(this, this.map, native_methods[i]);
      }

      this.createControl = function(options) {
        var control = doc.createElement('div');

        control.style.cursor = 'pointer';
        control.style.fontFamily = 'Arial, sans-serif';
        control.style.fontSize = '13px';
        control.style.boxShadow = 'rgba(0, 0, 0, 0.398438) 0px 2px 4px';

        for(var option in options.style)
          control.style[option] = options.style[option];

        if(options.id) {
          control.id = options.id;
        }

        if(options.classes) {
          control.className = options.classes;
        }

        if(options.content) {
          control.innerHTML = options.content;
        }

        for (var ev in options.events) {
          (function(object, name) {
            google.maps.event.addDomListener(object, name, function(){
              options.events[name].apply(this, [this]);
            });
          })(control, ev);
        }

        control.index = 1;

        return control;
      };

      this.addControl = function(options) {
        var position = google.maps.ControlPosition[options.position.toUpperCase()];

        delete options.position;

        var control = this.createControl(options);
        this.controls.push(control);
        this.map.controls[position].push(control);

        return control;
      };

      // Markers
      this.createMarker = function(options) {
        if ((options.hasOwnProperty('lat') && options.hasOwnProperty('lng')) || options.position) {
          var self = this;
          var details = options.details;
          var fences = options.fences;
          var outside = options.outside;

          var base_options = {
            position: new google.maps.LatLng(options.lat, options.lng),
            map: null
          };

          delete options.lat;
          delete options.lng;
          delete options.fences;
          delete options.outside;

          var marker_options = extend_object(base_options, options);

          var marker = new google.maps.Marker(marker_options);

          marker.fences = fences;

          if (options.infoWindow) {
            marker.infoWindow = new google.maps.InfoWindow(options.infoWindow);

            var info_window_events = ['closeclick', 'content_changed', 'domready', 'position_changed', 'zindex_changed'];

            for (var ev = 0; ev < info_window_events.length; ev++) {
              (function(object, name) {
                google.maps.event.addListener(object, name, function(e){
                  if (options.infoWindow[name])
                    options.infoWindow[name].apply(this, [e]);
                });
              })(marker.infoWindow, info_window_events[ev]);
            }
          }

          var marker_events = ['animation_changed', 'clickable_changed', 'cursor_changed', 'draggable_changed', 'flat_changed', 'icon_changed', 'position_changed', 'shadow_changed', 'shape_changed', 'title_changed', 'visible_changed', 'zindex_changed'];

          var marker_events_with_mouse = ['dblclick', 'drag', 'dragend', 'dragstart', 'mousedown', 'mouseout', 'mouseover', 'mouseup'];

          for (var ev = 0; ev < marker_events.length; ev++) {
            (function(object, name) {
              google.maps.event.addListener(object, name, function(){
                if (options[name])
                  options[name].apply(this, [this]);
              });
            })(marker, marker_events[ev]);
          }

          for (var ev = 0; ev < marker_events_with_mouse.length; ev++) {
            (function(map, object, name) {
              google.maps.event.addListener(object, name, function(me){
                if(!me.pixel){
                  me.pixel = map.getProjection().fromLatLngToPoint(me.latLng)
                }
                if (options[name])
                  options[name].apply(this, [me]);
              });
            })(this.map, marker, marker_events_with_mouse[ev]);
          }

          google.maps.event.addListener(marker, 'click', function() {
            this.details = details;

            if (options.click) {
              options.click.apply(this, [this]);
            }

            if (marker.infoWindow) {
              self.hideInfoWindows();
              marker.infoWindow.open(self.map, marker);
            }
          });

          google.maps.event.addListener(marker, 'rightclick', function(e) {
            e.marker = this;

            if (options.rightclick) {
              options.rightclick.apply(this, [e]);
            }

            if (window.context_menu['marker'] != undefined) {
              buildContextMenu('marker', e);
            }
          });

          if (options.dragend || marker.fences) {
            google.maps.event.addListener(marker, 'dragend', function() {
              if (marker.fences) {
                self.checkMarkerGeofence(marker, function(m, f) {
                  outside(m, f);
                });
              }
            });
          }

          return marker;
        }
        else {
          throw 'No latitude or longitude defined';
        }
      };

      this.addMarker = function(options) {
        var marker;
        if(options.hasOwnProperty('gm_accessors_')) {
          // Native google.maps.Marker object
          marker = options;
        }
        else {
          if ((options.hasOwnProperty('lat') && options.hasOwnProperty('lng')) || options.position) {
            marker = this.createMarker(options);
          }
          else {
            throw 'No latitude or longitude defined';
          }
        }

        marker.setMap(this.map);

        if(this.markerClusterer)
          this.markerClusterer.addMarker(marker);

        this.markers.push(marker);

        return marker;
      };

      this.addMarkers = function(array) {
        for (var i=0, marker; marker=array[i]; i++) {
          this.addMarker(marker);
        }
        return this.markers;
      };

      this.hideInfoWindows = function() {
        for (var i=0, marker; marker=this.markers[i]; i++){
          if (marker.infoWindow){
            marker.infoWindow.close();
          }
        }
      };

      this.removeMarker = function(marker) {
        for(var i = 0; i < this.markers.length; i++) {
          if(this.markers[i] === marker) {
            this.markers[i].setMap(null);
            this.markers.splice(i, 1);

            break;
          }
        }

        return marker;
      };

      this.removeMarkers = function(collection) {
        var collection = (collection || this.markers);
          
        for(var i=0;i < this.markers.length; i++){
          if(this.markers[i] === collection[i])
            this.markers[i].setMap(null);
        }

        var new_markers = [];

        for(var i=0;i < this.markers.length; i++){
          if(this.markers[i].getMap() != null)
            new_markers.push(this.markers[i]);
        }

        this.markers = new_markers;
      };

      // Overlays

      this.drawOverlay = function(options) {
        var overlay = new google.maps.OverlayView();
        overlay.setMap(self.map);

        var auto_show = true;

        if(options.auto_show != null)
          auto_show = options.auto_show;

        overlay.onAdd = function() {
          var el = doc.createElement('div');
          el.style.borderStyle = "none";
          el.style.borderWidth = "0px";
          el.style.position = "absolute";
          el.style.zIndex = 100;
          el.innerHTML = options.content;

          overlay.el = el;

          var panes = this.getPanes();
          if (!options.layer) {
            options.layer = 'overlayLayer';
          }
          var overlayLayer = panes[options.layer];
          overlayLayer.appendChild(el);

          var stop_overlay_events = ['contextmenu', 'DOMMouseScroll', 'dblclick', 'mousedown'];

          for (var ev = 0; ev < stop_overlay_events.length; ev++) {
            (function(object, name) {
              google.maps.event.addDomListener(object, name, function(e){
                if(navigator.userAgent.toLowerCase().indexOf('msie') != -1 && document.all) {
                  e.cancelBubble = true;
                  e.returnValue = false;
                }
                else {
                  e.stopPropagation();
                }
              });
            })(el, stop_overlay_events[ev]);
          }

          google.maps.event.trigger(this, 'ready');
        };

        overlay.draw = function() {
          var projection = this.getProjection();
          var pixel = projection.fromLatLngToDivPixel(new google.maps.LatLng(options.lat, options.lng));

          options.horizontalOffset = options.horizontalOffset || 0;
          options.verticalOffset = options.verticalOffset || 0;

          var el = overlay.el;
          var content = el.children[0];

          var content_height = content.clientHeight;
          var content_width = content.clientWidth;

          switch (options.verticalAlign) {
            case 'top':
              el.style.top = (pixel.y - content_height + options.verticalOffset) + 'px';
              break;
            default:
            case 'middle':
              el.style.top = (pixel.y - (content_height / 2) + options.verticalOffset) + 'px';
              break;
            case 'bottom':
              el.style.top = (pixel.y + options.verticalOffset) + 'px';
              break;
          }

          switch (options.horizontalAlign) {
            case 'left':
              el.style.left = (pixel.x - content_width + options.horizontalOffset) + 'px';
              break;
            default:
            case 'center':
              el.style.left = (pixel.x - (content_width / 2) + options.horizontalOffset) + 'px';
              break;
            case 'right':
              el.style.left = (pixel.x + options.horizontalOffset) + 'px';
              break;
          }

          el.style.display = auto_show ? 'block' : 'none';

          if(!auto_show){
            options.show.apply(this, [el]);
          }
        };

        overlay.onRemove = function() {
          var el = overlay.el;

          if(options.remove){
            options.remove.apply(this, [el]);
          }
          else{
            overlay.el.parentNode.removeChild(overlay.el);
            overlay.el = null;
          }
        };

        self.overlays.push(overlay);
        return overlay;
      };

      this.removeOverlay = function(overlay) {
        for(var i = 0; i < this.overlays.length; i++) {
          if(this.overlays[i] === overlay) {
            this.overlays[i].setMap(null);
            this.overlays.splice(i, 1);

            break;
          }
        }
      };

      this.removeOverlays = function() {
        for (var i=0, item; item=self.overlays[i]; i++){
          item.setMap(null);
        }
        self.overlays = [];
      };

      // Geometry

      this.drawPolyline = function(options) {
        var path = [];
        var points = options.path;

        if (points.length){
          if (points[0][0] === undefined){
            path = points;
          }
          else {
            for (var i=0, latlng; latlng=points[i]; i++){
              path.push(new google.maps.LatLng(latlng[0], latlng[1]));
            }
          }
        }

        var polyline_options = {
          map: this.map,
          path: path,
          strokeColor: options.strokeColor,
          strokeOpacity: options.strokeOpacity,
          strokeWeight: options.strokeWeight,
          geodesic: options.geodesic,
          clickable: true,
          editable: false,
          visible: true
        };

        if(options.hasOwnProperty("clickable"))
          polyline_options.clickable = options.clickable;

        if(options.hasOwnProperty("editable"))
          polyline_options.editable = options.editable;

        if(options.hasOwnProperty("icons"))
          polyline_options.icons = options.icons;

        if(options.hasOwnProperty("zIndex"))
          polyline_options.zIndex = options.zIndex;

        var polyline = new google.maps.Polyline(polyline_options);

        var polyline_events = ['click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover', 'mouseup', 'rightclick'];

        for (var ev = 0; ev < polyline_events.length; ev++) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              if (options[name])
                options[name].apply(this, [e]);
            });
          })(polyline, polyline_events[ev]);
        }

        this.polylines.push(polyline);

        return polyline;
      };

      this.removePolyline = function(polyline) {
        for(var i = 0; i < this.polylines.length; i++) {
          if(this.polylines[i] === polyline) {
            this.polylines[i].setMap(null);
            this.polylines.splice(i, 1);
            
            break;
          }
        }
      };

      this.removePolylines = function() {
        for (var i=0, item; item=self.polylines[i]; i++){
          item.setMap(null);
        }
        self.polylines = [];
      };

      this.drawCircle = function(options) {
        options =  extend_object({
          map: this.map,
          center: new google.maps.LatLng(options.lat, options.lng)
        }, options);

        delete options.lat;
        delete options.lng;
        var polygon = new google.maps.Circle(options);

        var polygon_events = ['click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover', 'mouseup', 'rightclick'];

        for (var ev = 0; ev < polygon_events.length; ev++) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              if (options[name])
                options[name].apply(this, [e]);
            });
          })(polygon, polygon_events[ev]);
        }

        this.polygons.push(polygon);

        return polygon;
      };
      
      this.drawRectangle = function(options) {
        options = extend_object({
          map: this.map
        }, options);

        var latLngBounds = new google.maps.LatLngBounds(
          new google.maps.LatLng(options.bounds[0][0], options.bounds[0][1]),
          new google.maps.LatLng(options.bounds[1][0], options.bounds[1][1])
        );
        
        options.bounds = latLngBounds;

        var polygon = new google.maps.Rectangle(options);

        var polygon_events = ['click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover', 'mouseup', 'rightclick'];

        for (var ev = 0; ev < polygon_events.length; ev++) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              if (options[name])
                options[name].apply(this, [e]);
            });
          })(polygon, polygon_events[ev]);
        }
        
        this.polygons.push(polygon);
        
        return polygon;
      };

      this.drawPolygon = function(options) {
        var useGeoJSON = false;
        if(options.hasOwnProperty("useGeoJSON"))
          useGeoJSON = options.useGeoJSON;

        delete options.useGeoJSON;

        options = extend_object({
          map: this.map
        }, options);

        if(useGeoJSON == false)
          options.paths = [options.paths.slice(0)];

        if(options.paths.length > 0) {
          if(options.paths[0].length > 0) {
            options.paths = array_flat(array_map(options.paths, arrayToLatLng, useGeoJSON));
          }
        }

        var polygon = new google.maps.Polygon(options);

        var polygon_events = ['click', 'dblclick', 'mousedown', 'mousemove', 'mouseout', 'mouseover', 'mouseup', 'rightclick'];

        for (var ev = 0; ev < polygon_events.length; ev++) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              if (options[name])
                options[name].apply(this, [e]);
            });
          })(polygon, polygon_events[ev]);
        }

        this.polygons.push(polygon);

        return polygon;
      };

      this.removePolygon = function(polygon) {
        for(var i = 0; i < this.polygons.length; i++) {
          if(this.polygons[i] === polygon) {
            this.polygons[i].setMap(null);
            this.polygons.splice(i, 1);
            
            break;
          }
        }
      };

      this.removePolygons = function() {
        for (var i=0, item; item=self.polygons[i]; i++){
          item.setMap(null);
        }
        self.polygons = [];
      };

      // Fusion Tables

      this.getFromFusionTables = function(options) {
        var events = options.events;

        delete options.events;

        var fusion_tables_options = options;

        var layer = new google.maps.FusionTablesLayer(fusion_tables_options);

        for (var ev in events) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              events[name].apply(this, [e]);
            });
          })(layer, ev);
        }

        this.layers.push(layer);

        return layer;
      };

      this.loadFromFusionTables = function(options) {
        var layer = this.getFromFusionTables(options);
        layer.setMap(this.map);

        return layer;
      };

      // KML

      this.getFromKML = function(options) {
        var url = options.url;
        var events = options.events;

        delete options.url;
        delete options.events;

        var kml_options = options;

        var layer = new google.maps.KmlLayer(url, kml_options);

        for (var ev in events) {
          (function(object, name) {
            google.maps.event.addListener(object, name, function(e){
              events[name].apply(this, [e]);
            });
          })(layer, ev);
        }

        this.layers.push(layer);

        return layer;
      };

      this.loadFromKML = function(options) {
        var layer = this.getFromKML(options);
        layer.setMap(this.map);

        return layer;
      };

      // Routes

      var travelMode, unitSystem;
      this.getRoutes = function(options) {
        switch (options.travelMode) {
        case 'bicycling':
          travelMode = google.maps.TravelMode.BICYCLING;
          break;
        case 'transit':
          travelMode = google.maps.TravelMode.TRANSIT;
          break;
        case 'driving':
          travelMode = google.maps.TravelMode.DRIVING;
          break;
        // case 'walking':
        default:
          travelMode = google.maps.TravelMode.WALKING;
          break;
        }

        if (options.unitSystem === 'imperial') {
          unitSystem = google.maps.UnitSystem.IMPERIAL;
        }
        else {
          unitSystem = google.maps.UnitSystem.METRIC;
        }

        var base_options = {
          avoidHighways: false,
          avoidTolls: false,
          optimizeWaypoints: false,
          waypoints: []
        };

        var request_options =  extend_object(base_options, options);

        request_options.origin = new google.maps.LatLng(options.origin[0], options.origin[1]);
        request_options.destination = new google.maps.LatLng(options.destination[0], options.destination[1]);
        request_options.travelMode = travelMode;
        request_options.unitSystem = unitSystem;

        delete request_options.callback;

        var self = this;
        var service = new google.maps.DirectionsService();

        service.route(request_options, function(result, status) {
          if (status === google.maps.DirectionsStatus.OK) {
            for (var r in result.routes) {
              if (result.routes.hasOwnProperty(r)) {
                self.routes.push(result.routes[r]);
              }
            }
          }
          if (options.callback) {
            options.callback(self.routes);
          }
        });
      };

      this.removeRoutes = function() {
        this.routes = [];
      };

      this.getElevations = function(options) {
        options = extend_object({
          locations: [],
          path : false,
          samples : 256
        }, options);

        if(options.locations.length > 0) {
          if(options.locations[0].length > 0) {
            options.locations = array_flat(array_map([options.locations], arrayToLatLng,  false));
          }
        }

        var callback = options.callback;
        delete options.callback;

        var service = new google.maps.ElevationService();

        //location request
        if (!options.path) {
          delete options.path;
          delete options.samples;
          service.getElevationForLocations(options, function(result, status){
            if (callback && typeof(callback) === "function") {
              callback(result, status);
            }
          });
        //path request
        } else {
          var pathRequest = {
            path : options.locations,
            samples : options.samples
          };

          service.getElevationAlongPath(pathRequest, function(result, status){
           if (callback && typeof(callback) === "function") {
              callback(result, status);
            }
          });
        }
      };

      // Alias for the method "drawRoute"
      this.cleanRoute = this.removePolylines;

      this.drawRoute = function(options) {
        var self = this;
        this.getRoutes({
          origin: options.origin,
          destination: options.destination,
          travelMode: options.travelMode,
          waypoints: options.waypoints,
          unitSystem: options.unitSystem,
          callback: function(e) {
            if (e.length > 0) {
              self.drawPolyline({
                path: e[e.length - 1].overview_path,
                strokeColor: options.strokeColor,
                strokeOpacity: options.strokeOpacity,
                strokeWeight: options.strokeWeight
              });
              if (options.callback) {
                options.callback(e[e.length - 1]);
              }
            }
          }
        });
      };

      this.travelRoute = function(options) {
        if (options.origin && options.destination) {
          this.getRoutes({
            origin: options.origin,
            destination: options.destination,
            travelMode: options.travelMode,
            waypoints : options.waypoints,
            callback: function(e) {
              //start callback
              if (e.length > 0 && options.start) {
                options.start(e[e.length - 1]);
              }

              //step callback
              if (e.length > 0 && options.step) {
                var route = e[e.length - 1];
                if (route.legs.length > 0) {
                  var steps = route.legs[0].steps;
                  for (var i=0, step; step=steps[i]; i++) {
                    step.step_number = i;
                    options.step(step, (route.legs[0].steps.length - 1));
                  }
                }
              }

              //end callback
              if (e.length > 0 && options.end) {
                 options.end(e[e.length - 1]);
              }
            }
          });
        }
        else if (options.route) {
          if (options.route.legs.length > 0) {
            var steps = options.route.legs[0].steps;
            for (var i=0, step; step=steps[i]; i++) {
              step.step_number = i;
              options.step(step);
            }
          }
        }
      };

      this.drawSteppedRoute = function(options) {
        if (options.origin && options.destination) {
          this.getRoutes({
            origin: options.origin,
            destination: options.destination,
            travelMode: options.travelMode,
            waypoints : options.waypoints,
            callback: function(e) {
              //start callback
              if (e.length > 0 && options.start) {
                options.start(e[e.length - 1]);
              }

              //step callback
              if (e.length > 0 && options.step) {
                var route = e[e.length - 1];
                if (route.legs.length > 0) {
                  var steps = route.legs[0].steps;
                  for (var i=0, step; step=steps[i]; i++) {
                    step.step_number = i;
                    self.drawPolyline({
                      path: step.path,
                      strokeColor: options.strokeColor,
                      strokeOpacity: options.strokeOpacity,
                      strokeWeight: options.strokeWeight
                    });
                    options.step(step, (route.legs[0].steps.length - 1));
                  }
                }
              }

              //end callback
              if (e.length > 0 && options.end) {
                 options.end(e[e.length - 1]);
              }
            }
          });
        }
        else if (options.route) {
          if (options.route.legs.length > 0) {
            var steps = options.route.legs[0].steps;
            for (var i=0, step; step=steps[i]; i++) {
              step.step_number = i;
              self.drawPolyline({
                path: step.path,
                strokeColor: options.strokeColor,
                strokeOpacity: options.strokeOpacity,
                strokeWeight: options.strokeWeight
              });
              options.step(step);
            }
          }
        }
      };

      // Geofence

      this.checkGeofence = function(lat, lng, fence) {
        return fence.containsLatLng(new google.maps.LatLng(lat, lng));
      };

      this.checkMarkerGeofence = function(marker, outside_callback) {
        if (marker.fences) {
          for (var i=0, fence; fence=marker.fences[i]; i++) {
            var pos = marker.getPosition();
            if (!self.checkGeofence(pos.lat(), pos.lng(), fence)) {
              outside_callback(marker, fence);
            }
          }
        }
      };

      // Layers

      this.addLayer = function(layerName, options) {
        //var default_layers = ['weather', 'clouds', 'traffic', 'transit', 'bicycling', 'panoramio', 'places'];
        options = options || {};
        var layer;
          
        switch(layerName) {
          case 'weather': this.singleLayers.weather = layer = new google.maps.weather.WeatherLayer(); 
            break;
          case 'clouds': this.singleLayers.clouds = layer = new google.maps.weather.CloudLayer(); 
            break;
          case 'traffic': this.singleLayers.traffic = layer = new google.maps.TrafficLayer(); 
            break;
          case 'transit': this.singleLayers.transit = layer = new google.maps.TransitLayer(); 
            break;
          case 'bicycling': this.singleLayers.bicycling = layer = new google.maps.BicyclingLayer(); 
            break;
          case 'panoramio': 
              this.singleLayers.panoramio = layer = new google.maps.panoramio.PanoramioLayer();
              layer.setTag(options.filter);
              delete options.filter;

              //click event
              if(options.click) {
                google.maps.event.addListener(layer, 'click', function(event) {
                  options.click(event);
                  delete options.click;
                });
              }
            break;
            case 'places': 
              this.singleLayers.places = layer = new google.maps.places.PlacesService(this.map);

              //search and  nearbySearch callback, Both are the same
              if(options.search || options.nearbySearch) {
                var placeSearchRequest  = {
                  bounds : options.bounds || null,
                  keyword : options.keyword || null,
                  location : options.location || null,
                  name : options.name || null,
                  radius : options.radius || null,
                  rankBy : options.rankBy || null,
                  types : options.types || null
                };

                if(options.search) {
                  layer.search(placeSearchRequest, options.search);
                }

                if(options.nearbySearch) {
                  layer.nearbySearch(placeSearchRequest, options.nearbySearch);
                }
              }

              //textSearch callback
              if(options.textSearch) {
                var textSearchRequest  = {
                  bounds : options.bounds || null,
                  location : options.location || null,
                  query : options.query || null,
                  radius : options.radius || null
                };
                
                layer.textSearch(textSearchRequest, options.textSearch);
              }
            break;
        }

        if(layer !== undefined) {
          if(typeof layer.setOptions == 'function') {
            layer.setOptions(options);
          }
          if(typeof layer.setMap == 'function') {
            layer.setMap(this.map);
          }

          return layer;
        }
      };

      this.removeLayer = function(layerName) {
        if(this.singleLayers[layerName] !== undefined) {
           this.singleLayers[layerName].setMap(null);
           delete this.singleLayers[layerName];
        }
      };
      
      // Static Maps

      this.toImage = function(options) {
        var options = options || {};
        var static_map_options = {};
        static_map_options['size'] = options['size'] || [this.el.clientWidth, this.el.clientHeight];
        static_map_options['lat'] = this.getCenter().lat();
        static_map_options['lng'] = this.getCenter().lng();

        if(this.markers.length > 0) {
          static_map_options['markers'] = [];
          for(var i=0; i < this.markers.length; i++) {
            static_map_options['markers'].push({
              lat: this.markers[i].getPosition().lat(),
              lng: this.markers[i].getPosition().lng()
            });
          }
        }

        if(this.polylines.length > 0) {
          var polyline = this.polylines[0];
          static_map_options['polyline'] = {};
          static_map_options['polyline']['path'] = google.maps.geometry.encoding.encodePath(polyline.getPath());
          static_map_options['polyline']['strokeColor'] = polyline.strokeColor
          static_map_options['polyline']['strokeOpacity'] = polyline.strokeOpacity
          static_map_options['polyline']['strokeWeight'] = polyline.strokeWeight
        }
        
        return GMaps.staticMapURL(static_map_options);
      };

      // Map Types

      this.addMapType = function(mapTypeId, options) {
        if(options.hasOwnProperty("getTileUrl") && typeof(options["getTileUrl"]) == "function") {
          options.tileSize = options.tileSize || new google.maps.Size(256, 256);
          
          var mapType = new google.maps.ImageMapType(options);

          this.map.mapTypes.set(mapTypeId, mapType);
        }
        else {
          throw "'getTileUrl' function required";
        }
      };

      this.addOverlayMapType = function(options) {
        if(options.hasOwnProperty("getTile") && typeof(options["getTile"]) == "function") {
          var overlayMapTypeIndex = options.index;

          delete options.index;

          this.map.overlayMapTypes.insertAt(overlayMapTypeIndex, options);
        }
        else {
          throw "'getTile' function required";
        }
      };

      this.removeOverlayMapType = function(overlayMapTypeIndex) {
        this.map.overlayMapTypes.removeAt(overlayMapTypeIndex);
      };

      // Styles
      
      this.addStyle = function(options) {       
        var styledMapType = new google.maps.StyledMapType(options.styles, options.styledMapName);
        
        this.map.mapTypes.set(options.mapTypeId, styledMapType);
      };
      
      this.setStyle = function(mapTypeId) {     
        this.map.setMapTypeId(mapTypeId);
      };

      // StreetView

      this.createPanorama = function(streetview_options) {
        if (!streetview_options.hasOwnProperty('lat') || !streetview_options.hasOwnProperty('lng')) {
          streetview_options.lat = this.getCenter().lat();
          streetview_options.lng = this.getCenter().lng();
        }

        this.panorama = GMaps.createPanorama(streetview_options);

        this.map.setStreetView(this.panorama);

        return this.panorama;
      };
    };

    GMaps.createPanorama = function(options) {
      var el = getElementById(options.el, options.context);

      options.position = new google.maps.LatLng(options.lat, options.lng);

      delete options.el;
      delete options.context;
      delete options.lat;
      delete options.lng;

      var streetview_events = ['closeclick', 'links_changed', 'pano_changed', 'position_changed', 'pov_changed', 'resize', 'visible_changed'];

      var streetview_options = extend_object({visible : true}, options);

      for(var i = 0; i < streetview_events.length; i++) {
        delete streetview_options[streetview_events[i]];
      }

      var panorama = new google.maps.StreetViewPanorama(el, streetview_options);

      for(var i = 0; i < streetview_events.length; i++) {
        (function(object, name) {
          google.maps.event.addListener(object, name, function(){
            if (options[name]) {
              options[name].apply(this);
            }
          });
        })(panorama, streetview_events[i]);
      }

      return panorama;
    };

    GMaps.Route = function(options) {
      this.map = options.map;
      this.route = options.route;
      this.step_count = 0;
      this.steps = this.route.legs[0].steps;
      this.steps_length = this.steps.length;

      this.polyline = this.map.drawPolyline({
        path: new google.maps.MVCArray(),
        strokeColor: options.strokeColor,
        strokeOpacity: options.strokeOpacity,
        strokeWeight: options.strokeWeight
      }).getPath();

      this.back = function() {
        if (this.step_count > 0) {
          this.step_count--;
          var path = this.route.legs[0].steps[this.step_count].path;
          for (var p in path){
            if (path.hasOwnProperty(p)){
              this.polyline.pop();
            }
          }
        }
      };

      this.forward = function() {
        if (this.step_count < this.steps_length) {
          var path = this.route.legs[0].steps[this.step_count].path;
          for (var p in path){
            if (path.hasOwnProperty(p)){
              this.polyline.push(path[p]);
            }
          }
          this.step_count++;
        }
      };
    };

    // Geolocation (Modern browsers only)
    GMaps.geolocate = function(options) {
      var complete_callback = options.always || options.complete;

      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
          options.success(position);

          if (complete_callback) {
            complete_callback();
          }
        }, function(error) {
          options.error(error);

          if (complete_callback) {
            complete_callback();
          }
        }, options.options);
      }
      else {
        options.not_supported();

        if (complete_callback) {
          complete_callback();
        }
      }
    };

    // Geocoding
    GMaps.geocode = function(options) {
      this.geocoder = new google.maps.Geocoder();
      var callback = options.callback;
      if (options.hasOwnProperty('lat') && options.hasOwnProperty('lng')) {
        options.latLng = new google.maps.LatLng(options.lat, options.lng);
      }

      delete options.lat;
      delete options.lng;
      delete options.callback;
      this.geocoder.geocode(options, function(results, status) {
        callback(results, status);
      });
    };

    // Static maps
    GMaps.staticMapURL = function(options){
      var parameters = [];
      var data;

      var static_root = 'http://maps.googleapis.com/maps/api/staticmap';
      if (options.url){
        static_root = options.url;
        delete options.url;
      }
      static_root += '?';

      var markers = options.markers;
      delete options.markers;
      if (!markers && options.marker){
        markers = [options.marker];
        delete options.marker;
      }

      var polyline = options.polyline;
      delete options.polyline;

      /** Map options **/
      if (options.center){
        parameters.push('center=' + options.center);
        delete options.center;
      }
      else if (options.address){
        parameters.push('center=' + options.address);
        delete options.address;
      }
      else if (options.lat){
        parameters.push(['center=', options.lat, ',', options.lng].join(''));
        delete options.lat;
        delete options.lng;
      }
      else if (options.visible){
        var visible = encodeURI(options.visible.join('|'));
        parameters.push('visible=' + visible);
      }

      var size = options.size;
      if (size){
        if (size.join){
          size = size.join('x');
        }
        delete options.size;
      }
      else {
        size = '630x300';
      }
      parameters.push('size=' + size);

      if (!options.zoom){
        options.zoom = 15;
      }

      var sensor = options.hasOwnProperty('sensor') ? !!options.sensor : true;
      delete options.sensor;
      parameters.push('sensor=' + sensor);

      for (var param in options){
        if (options.hasOwnProperty(param)){
          parameters.push(param + '=' + options[param]);
        }
      }

      /** Markers **/
      if (markers){
        var marker, loc;

        for (var i=0; data=markers[i]; i++){
          marker = [];

          if (data.size && data.size !== 'normal'){
            marker.push('size:' + data.size);
          }
          else if (data.icon){
            marker.push('icon:' + encodeURI(data.icon));
          }

          if (data.color){
            marker.push('color:' + data.color.replace('#', '0x'));
          }

          if (data.label){
            marker.push('label:' + data.label[0].toUpperCase());
          }

          loc = (data.address ? data.address : data.lat + ',' + data.lng);

          if (marker.length || i === 0){
            marker.push(loc);
            marker = marker.join('|');
            parameters.push('markers=' + encodeURI(marker));
          }
          // New marker without styles
          else {
            marker = parameters.pop() + encodeURI('|' + loc);
            parameters.push(marker);
          }
        }
      }

      /** Polylines **/
      function parseColor(color, opacity){
        if (color[0] === '#'){
          color = color.replace('#', '0x');

          if (opacity){
            opacity = parseFloat(opacity);
            opacity = Math.min(1, Math.max(opacity, 0));
            if (opacity === 0){
              return '0x00000000';
            }
            opacity = (opacity * 255).toString(16);
            if (opacity.length === 1){
              opacity += opacity;
            }

            color = color.slice(0,8) + opacity;
          }
        }
        return color;
      }

      if (polyline){
        data = polyline;
        polyline = [];

        if (data.strokeWeight){
          polyline.push('weight:' + parseInt(data.strokeWeight, 10));
        }

        if (data.strokeColor){
          var color = parseColor(data.strokeColor, data.strokeOpacity);
          polyline.push('color:' + color);
        }

        if (data.fillColor){
          var fillcolor = parseColor(data.fillColor, data.fillOpacity);
          polyline.push('fillcolor:' + fillcolor);
        }

        var path = data.path;
        if (path.join){
          for (var j=0, pos; pos=path[j]; j++){
            polyline.push(pos.join(','));
          }
        }
        else {
          polyline.push('enc:' + path);
        }

        polyline = polyline.join('|');
        parameters.push('path=' + encodeURI(polyline));
      }

      parameters = parameters.join('&');
      return static_root + parameters;
    };

    //==========================
    // Polygon containsLatLng
    // https://github.com/tparkin/Google-Maps-Point-in-Polygon
    // Poygon getBounds extension - google-maps-extensions
    // http://code.google.com/p/google-maps-extensions/source/browse/google.maps.Polygon.getBounds.js
    if (!google.maps.Polygon.prototype.getBounds) {
      google.maps.Polygon.prototype.getBounds = function(latLng) {
        var bounds = new google.maps.LatLngBounds();
        var paths = this.getPaths();
        var path;

        for (var p = 0; p < paths.getLength(); p++) {
          path = paths.getAt(p);
          for (var i = 0; i < path.getLength(); i++) {
            bounds.extend(path.getAt(i));
          }
        }

        return bounds;
      };
    }

    if (!google.maps.Polygon.prototype.containsLatLng) {
      // Polygon containsLatLng - method to determine if a latLng is within a polygon
      google.maps.Polygon.prototype.containsLatLng = function(latLng) {
        // Exclude points outside of bounds as there is no way they are in the poly
        var bounds = this.getBounds();

        if (bounds !== null && !bounds.contains(latLng)) {
          return false;
        }

        // Raycast point in polygon method
        var inPoly = false;

        var numPaths = this.getPaths().getLength();
        for (var p = 0; p < numPaths; p++) {
          var path = this.getPaths().getAt(p);
          var numPoints = path.getLength();
          var j = numPoints - 1;

          for (var i = 0; i < numPoints; i++) {
            var vertex1 = path.getAt(i);
            var vertex2 = path.getAt(j);

            if (vertex1.lng() < latLng.lng() && vertex2.lng() >= latLng.lng() || vertex2.lng() < latLng.lng() && vertex1.lng() >= latLng.lng()) {
              if (vertex1.lat() + (latLng.lng() - vertex1.lng()) / (vertex2.lng() - vertex1.lng()) * (vertex2.lat() - vertex1.lat()) < latLng.lat()) {
                inPoly = !inPoly;
              }
            }

            j = i;
          }
        }

        return inPoly;
      };
    }

    google.maps.LatLngBounds.prototype.containsLatLng = function(latLng) {
      return this.contains(latLng);
    };

    google.maps.Marker.prototype.setFences = function(fences) {
      this.fences = fences;
    };

    google.maps.Marker.prototype.addFence = function(fence) {
      this.fences.push(fence);
    };

    return GMaps;
  }(this));

  var coordsToLatLngs = function(coords, useGeoJSON) {
    var first_coord = coords[0];
    var second_coord = coords[1];

    if(useGeoJSON) {
      first_coord = coords[1];
      second_coord = coords[0];
    }

    return new google.maps.LatLng(first_coord, second_coord);
  };

  var arrayToLatLng = function(coords, useGeoJSON) {
    for(var i=0; i < coords.length; i++) {
      if(coords[i].length > 0 && typeof(coords[i][0]) != "number") {
        coords[i] = arrayToLatLng(coords[i], useGeoJSON);
      }
      else {
        coords[i] = coordsToLatLngs(coords[i], useGeoJSON);
      }
    }

    return coords;
  };

  var extend_object = function(obj, new_obj) {
    if(obj === new_obj) return obj;

    for(var name in new_obj) {
      obj[name] = new_obj[name];
    }

    return obj;
  };

  var replace_object = function(obj, replace) {
    if(obj === replace) return obj;

    for(var name in replace) {
      if(obj[name] != undefined)
        obj[name] = replace[name];
    }

    return obj;
  };

  var array_map = function(array, callback) {
    var original_callback_params = Array.prototype.slice.call(arguments, 2);

    if (Array.prototype.map && array.map === Array.prototype.map) {
      return Array.prototype.map.call(array, function(item) {
        callback_params = original_callback_params;
        callback_params.splice(0, 0, item);

        return callback.apply(this, callback_params);
      });
    }
    else {
      var array_return = [];
      var array_length = array.length;

      for(var i = 0; i < array_length; i++) {
        callback_params = original_callback_params;
        callback_params = callback_params.splice(0, 0, array[i]);
        array_return.push(callback.apply(this, callback_params));
      }

      return array_return;
    }
  };

  var array_flat = function(array) {
    new_array = [];

    for(var i=0; i < array.length; i++) {
      new_array = new_array.concat(array[i]);
    }

    return new_array;
  };

}
;

/** @preserve OverlappingMarkerSpiderfier
https://github.com/jawj/OverlappingMarkerSpiderfier
Copyright (c) 2011 - 2012 George MacKerron
Released under the MIT licence: http://opensource.org/licenses/mit-license
Note: The Google Maps API v3 must be included *before* this code
*/


(function() {
  var _ref,
    __hasProp = {}.hasOwnProperty,
    __slice = [].slice;

  if (((_ref = this['google']) != null ? _ref['maps'] : void 0) == null) {
    return;
  }

  this['OverlappingMarkerSpiderfier'] = (function() {
    var ge, gm, lcH, lcU, mt, p, twoPi;

    p = _Class.prototype;

    p['VERSION'] = '0.3';

    gm = google.maps;

    ge = gm.event;

    mt = gm.MapTypeId;

    twoPi = Math.PI * 2;

    p['keepSpiderfied'] = false;

    p['markersWontHide'] = false;

    p['markersWontMove'] = false;

    p['nearbyDistance'] = 20;

    p['circleSpiralSwitchover'] = 9;

    p['circleFootSeparation'] = 23;

    p['circleStartAngle'] = twoPi / 12;

    p['spiralFootSeparation'] = 26;

    p['spiralLengthStart'] = 11;

    p['spiralLengthFactor'] = 4;

    p['spiderfiedZIndex'] = 1000;

    p['usualLegZIndex'] = 10;

    p['highlightedLegZIndex'] = 20;

    p['legWeight'] = 1.5;

    p['legColors'] = {
      'usual': {},
      'highlighted': {}
    };

    lcU = p['legColors']['usual'];

    lcH = p['legColors']['highlighted'];

    lcU[mt.HYBRID] = lcU[mt.SATELLITE] = '#fff';

    lcH[mt.HYBRID] = lcH[mt.SATELLITE] = '#f00';

    lcU[mt.TERRAIN] = lcU[mt.ROADMAP] = '#444';

    lcH[mt.TERRAIN] = lcH[mt.ROADMAP] = '#f00';

    function _Class(map, opts) {
      var e, k, v, _i, _len, _ref1,
        _this = this;
      this.map = map;
      if (opts == null) {
        opts = {};
      }
      for (k in opts) {
        if (!__hasProp.call(opts, k)) continue;
        v = opts[k];
        this[k] = v;
      }
      this.projHelper = new this.constructor.ProjHelper(this.map);
      this.initMarkerArrays();
      this.listeners = {};
      _ref1 = ['click', 'zoom_changed', 'maptypeid_changed'];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        e = _ref1[_i];
        ge.addListener(this.map, e, function() {
          return _this['unspiderfy']();
        });
      }
    }

    p.initMarkerArrays = function() {
      this.markers = [];
      return this.markerListenerRefs = [];
    };

    p['addMarker'] = function(marker) {
      var listenerRefs,
        _this = this;
      if (marker['_oms'] != null) {
        return this;
      }
      marker['_oms'] = true;
      listenerRefs = [
        ge.addListener(marker, 'click', function() {
          return _this.spiderListener(marker);
        })
      ];
      if (!this['markersWontHide']) {
        listenerRefs.push(ge.addListener(marker, 'visible_changed', function() {
          return _this.markerChangeListener(marker, false);
        }));
      }
      if (!this['markersWontMove']) {
        listenerRefs.push(ge.addListener(marker, 'position_changed', function() {
          return _this.markerChangeListener(marker, true);
        }));
      }
      this.markerListenerRefs.push(listenerRefs);
      this.markers.push(marker);
      return this;
    };

    p.markerChangeListener = function(marker, positionChanged) {
      if ((marker['_omsData'] != null) && (positionChanged || !marker.getVisible()) && !((this.spiderfying != null) || (this.unspiderfying != null))) {
        return this.unspiderfy(positionChanged ? marker : null);
      }
    };

    p['getMarkers'] = function() {
      return this.markers.slice(0);
    };

    p['removeMarker'] = function(marker) {
      var i, listenerRef, listenerRefs, _i, _len;
      if (marker['_omsData'] != null) {
        this['unspiderfy']();
      }
      i = this.arrIndexOf(this.markers, marker);
      if (i < 0) {
        return this;
      }
      listenerRefs = this.markerListenerRefs.splice(i, 1)[0];
      for (_i = 0, _len = listenerRefs.length; _i < _len; _i++) {
        listenerRef = listenerRefs[_i];
        ge.removeListener(listenerRef);
      }
      delete marker['_oms'];
      this.markers.splice(i, 1);
      return this;
    };

    p['clearMarkers'] = function() {
      var i, listenerRef, listenerRefs, marker, _i, _j, _len, _len1, _ref1;
      this['unspiderfy']();
      _ref1 = this.markers;
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        marker = _ref1[i];
        listenerRefs = this.markerListenerRefs[i];
        for (_j = 0, _len1 = listenerRefs.length; _j < _len1; _j++) {
          listenerRef = listenerRefs[_j];
          ge.removeListener(listenerRef);
        }
        delete marker['_oms'];
      }
      this.initMarkerArrays();
      return this;
    };

    p['addListener'] = function(event, func) {
      var _base, _ref1;
      ((_ref1 = (_base = this.listeners)[event]) != null ? _ref1 : _base[event] = []).push(func);
      return this;
    };

    p['removeListener'] = function(event, func) {
      var i;
      i = this.arrIndexOf(this.listeners[event], func);
      if (!(i < 0)) {
        this.listeners[event].splice(i, 1);
      }
      return this;
    };

    p['clearListeners'] = function(event) {
      this.listeners[event] = [];
      return this;
    };

    p.trigger = function() {
      var args, event, func, _i, _len, _ref1, _ref2, _results;
      event = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      _ref2 = (_ref1 = this.listeners[event]) != null ? _ref1 : [];
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        func = _ref2[_i];
        _results.push(func.apply(null, args));
      }
      return _results;
    };

    p.generatePtsCircle = function(count, centerPt) {
      var angle, angleStep, circumference, i, legLength, _i, _results;
      circumference = this['circleFootSeparation'] * (2 + count);
      legLength = circumference / twoPi;
      angleStep = twoPi / count;
      _results = [];
      for (i = _i = 0; 0 <= count ? _i < count : _i > count; i = 0 <= count ? ++_i : --_i) {
        angle = this['circleStartAngle'] + i * angleStep;
        _results.push(new gm.Point(centerPt.x + legLength * Math.cos(angle), centerPt.y + legLength * Math.sin(angle)));
      }
      return _results;
    };

    p.generatePtsSpiral = function(count, centerPt) {
      var angle, i, legLength, pt, _i, _results;
      legLength = this['spiralLengthStart'];
      angle = 0;
      _results = [];
      for (i = _i = 0; 0 <= count ? _i < count : _i > count; i = 0 <= count ? ++_i : --_i) {
        angle += this['spiralFootSeparation'] / legLength + i * 0.0005;
        pt = new gm.Point(centerPt.x + legLength * Math.cos(angle), centerPt.y + legLength * Math.sin(angle));
        legLength += twoPi * this['spiralLengthFactor'] / angle;
        _results.push(pt);
      }
      return _results;
    };

    p.spiderListener = function(marker) {
      var m, mPt, markerPt, markerSpiderfied, nDist, nearbyMarkerData, nonNearbyMarkers, pxSq, _i, _len, _ref1;
      markerSpiderfied = marker['_omsData'] != null;
      if (!(markerSpiderfied && this['keepSpiderfied'])) {
        this['unspiderfy']();
      }
      if (markerSpiderfied || this.map.getStreetView().getVisible()) {
        return this.trigger('click', marker);
      } else {
        nearbyMarkerData = [];
        nonNearbyMarkers = [];
        nDist = this['nearbyDistance'];
        pxSq = nDist * nDist;
        markerPt = this.llToPt(marker.position);
        _ref1 = this.markers;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          m = _ref1[_i];
          if (!((m.map != null) && m.getVisible())) {
            continue;
          }
          mPt = this.llToPt(m.position);
          if (this.ptDistanceSq(mPt, markerPt) < pxSq) {
            nearbyMarkerData.push({
              marker: m,
              markerPt: mPt
            });
          } else {
            nonNearbyMarkers.push(m);
          }
        }
        if (nearbyMarkerData.length === 1) {
          return this.trigger('click', marker);
        } else {
          return this.spiderfy(nearbyMarkerData, nonNearbyMarkers);
        }
      }
    };

    p['markersNearMarker'] = function(marker, firstOnly) {
      var m, mPt, markerPt, markers, nDist, pxSq, _i, _len, _ref1, _ref2, _ref3;
      if (firstOnly == null) {
        firstOnly = false;
      }
      if (this.projHelper.getProjection() == null) {
        throw "Must wait for 'idle' event on map before calling markersNearMarker";
      }
      nDist = this['nearbyDistance'];
      pxSq = nDist * nDist;
      markerPt = this.llToPt(marker.position);
      markers = [];
      _ref1 = this.markers;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        m = _ref1[_i];
        if (m === marker || (m.map == null) || !m.getVisible()) {
          continue;
        }
        mPt = this.llToPt((_ref2 = (_ref3 = m['_omsData']) != null ? _ref3.usualPosition : void 0) != null ? _ref2 : m.position);
        if (this.ptDistanceSq(mPt, markerPt) < pxSq) {
          markers.push(m);
          if (firstOnly) {
            break;
          }
        }
      }
      return markers;
    };

    p['markersNearAnyOtherMarker'] = function() {
      var i, i1, i2, m, m1, m1Data, m2, m2Data, mData, nDist, pxSq, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3, _results;
      if (this.projHelper.getProjection() == null) {
        throw "Must wait for 'idle' event on map before calling markersNearAnyOtherMarker";
      }
      nDist = this['nearbyDistance'];
      pxSq = nDist * nDist;
      mData = (function() {
        var _i, _len, _ref1, _ref2, _ref3, _results;
        _ref1 = this.markers;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          m = _ref1[_i];
          _results.push({
            pt: this.llToPt((_ref2 = (_ref3 = m['_omsData']) != null ? _ref3.usualPosition : void 0) != null ? _ref2 : m.position),
            willSpiderfy: false
          });
        }
        return _results;
      }).call(this);
      _ref1 = this.markers;
      for (i1 = _i = 0, _len = _ref1.length; _i < _len; i1 = ++_i) {
        m1 = _ref1[i1];
        if (!((m1.map != null) && m1.getVisible())) {
          continue;
        }
        m1Data = mData[i1];
        if (m1Data.willSpiderfy) {
          continue;
        }
        _ref2 = this.markers;
        for (i2 = _j = 0, _len1 = _ref2.length; _j < _len1; i2 = ++_j) {
          m2 = _ref2[i2];
          if (i2 === i1) {
            continue;
          }
          if (!((m2.map != null) && m2.getVisible())) {
            continue;
          }
          m2Data = mData[i2];
          if (i2 < i1 && !m2Data.willSpiderfy) {
            continue;
          }
          if (this.ptDistanceSq(m1Data.pt, m2Data.pt) < pxSq) {
            m1Data.willSpiderfy = m2Data.willSpiderfy = true;
            break;
          }
        }
      }
      _ref3 = this.markers;
      _results = [];
      for (i = _k = 0, _len2 = _ref3.length; _k < _len2; i = ++_k) {
        m = _ref3[i];
        if (mData[i].willSpiderfy) {
          _results.push(m);
        }
      }
      return _results;
    };

    p.makeHighlightListenerFuncs = function(marker) {
      var _this = this;
      return {
        highlight: function() {
          return marker['_omsData'].leg.setOptions({
            strokeColor: _this['legColors']['highlighted'][_this.map.mapTypeId],
            zIndex: _this['highlightedLegZIndex']
          });
        },
        unhighlight: function() {
          return marker['_omsData'].leg.setOptions({
            strokeColor: _this['legColors']['usual'][_this.map.mapTypeId],
            zIndex: _this['usualLegZIndex']
          });
        }
      };
    };

    p.spiderfy = function(markerData, nonNearbyMarkers) {
      var bodyPt, footLl, footPt, footPts, highlightListenerFuncs, leg, marker, md, nearestMarkerDatum, numFeet, spiderfiedMarkers;
      this.spiderfying = true;
      numFeet = markerData.length;
      bodyPt = this.ptAverage((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = markerData.length; _i < _len; _i++) {
          md = markerData[_i];
          _results.push(md.markerPt);
        }
        return _results;
      })());
      footPts = numFeet >= this['circleSpiralSwitchover'] ? this.generatePtsSpiral(numFeet, bodyPt).reverse() : this.generatePtsCircle(numFeet, bodyPt);
      spiderfiedMarkers = (function() {
        var _i, _len, _results,
          _this = this;
        _results = [];
        for (_i = 0, _len = footPts.length; _i < _len; _i++) {
          footPt = footPts[_i];
          footLl = this.ptToLl(footPt);
          nearestMarkerDatum = this.minExtract(markerData, function(md) {
            return _this.ptDistanceSq(md.markerPt, footPt);
          });
          marker = nearestMarkerDatum.marker;
          leg = new gm.Polyline({
            map: this.map,
            path: [marker.position, footLl],
            strokeColor: this['legColors']['usual'][this.map.mapTypeId],
            strokeWeight: this['legWeight'],
            zIndex: this['usualLegZIndex']
          });
          marker['_omsData'] = {
            usualPosition: marker.position,
            leg: leg
          };
          if (this['legColors']['highlighted'][this.map.mapTypeId] !== this['legColors']['usual'][this.map.mapTypeId]) {
            highlightListenerFuncs = this.makeHighlightListenerFuncs(marker);
            marker['_omsData'].hightlightListeners = {
              highlight: ge.addListener(marker, 'mouseover', highlightListenerFuncs.highlight),
              unhighlight: ge.addListener(marker, 'mouseout', highlightListenerFuncs.unhighlight)
            };
          }
          marker.setPosition(footLl);
          marker.setZIndex(Math.round(this['spiderfiedZIndex'] + footPt.y));
          _results.push(marker);
        }
        return _results;
      }).call(this);
      delete this.spiderfying;
      this.spiderfied = true;
      return this.trigger('spiderfy', spiderfiedMarkers, nonNearbyMarkers);
    };

    p['unspiderfy'] = function(markerNotToMove) {
      var listeners, marker, nonNearbyMarkers, unspiderfiedMarkers, _i, _len, _ref1;
      if (markerNotToMove == null) {
        markerNotToMove = null;
      }
      if (this.spiderfied == null) {
        return this;
      }
      this.unspiderfying = true;
      unspiderfiedMarkers = [];
      nonNearbyMarkers = [];
      _ref1 = this.markers;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        marker = _ref1[_i];
        if (marker['_omsData'] != null) {
          marker['_omsData'].leg.setMap(null);
          if (marker !== markerNotToMove) {
            marker.setPosition(marker['_omsData'].usualPosition);
          }
          marker.setZIndex(null);
          listeners = marker['_omsData'].hightlightListeners;
          if (listeners != null) {
            ge.removeListener(listeners.highlight);
            ge.removeListener(listeners.unhighlight);
          }
          delete marker['_omsData'];
          unspiderfiedMarkers.push(marker);
        } else {
          nonNearbyMarkers.push(marker);
        }
      }
      delete this.unspiderfying;
      delete this.spiderfied;
      this.trigger('unspiderfy', unspiderfiedMarkers, nonNearbyMarkers);
      return this;
    };

    p.ptDistanceSq = function(pt1, pt2) {
      var dx, dy;
      dx = pt1.x - pt2.x;
      dy = pt1.y - pt2.y;
      return dx * dx + dy * dy;
    };

    p.ptAverage = function(pts) {
      var numPts, pt, sumX, sumY, _i, _len;
      sumX = sumY = 0;
      for (_i = 0, _len = pts.length; _i < _len; _i++) {
        pt = pts[_i];
        sumX += pt.x;
        sumY += pt.y;
      }
      numPts = pts.length;
      return new gm.Point(sumX / numPts, sumY / numPts);
    };

    p.llToPt = function(ll) {
      return this.projHelper.getProjection().fromLatLngToDivPixel(ll);
    };

    p.ptToLl = function(pt) {
      return this.projHelper.getProjection().fromDivPixelToLatLng(pt);
    };

    p.minExtract = function(set, func) {
      var bestIndex, bestVal, index, item, val, _i, _len;
      for (index = _i = 0, _len = set.length; _i < _len; index = ++_i) {
        item = set[index];
        val = func(item);
        if ((typeof bestIndex === "undefined" || bestIndex === null) || val < bestVal) {
          bestVal = val;
          bestIndex = index;
        }
      }
      return set.splice(bestIndex, 1)[0];
    };

    p.arrIndexOf = function(arr, obj) {
      var i, o, _i, _len;
      if (arr.indexOf != null) {
        return arr.indexOf(obj);
      }
      for (i = _i = 0, _len = arr.length; _i < _len; i = ++_i) {
        o = arr[i];
        if (o === obj) {
          return i;
        }
      }
      return -1;
    };

    _Class.ProjHelper = function(map) {
      return this.setMap(map);
    };

    _Class.ProjHelper.prototype = new gm.OverlayView();

    _Class.ProjHelper.prototype['draw'] = function() {};

    return _Class;

  })();

}).call(this);
/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @name GeolocationMarker for Google Maps v3
 * @version version 1.0
 * @author Chad Killingsworth [chadkillingsworth at missouristate.edu]
 * Copyright 2012 Missouri State University
 * @fileoverview
 * This library uses geolocation to add a marker and accuracy circle to a map.
 * The marker position is automatically updated as the user position changes.
 */

/**
 * @constructor
 * @extends {google.maps.MVCObject}
 * @param {google.maps.Map=} opt_map
 * @param {(google.maps.MarkerOptions|Object.<string>)=} opt_markerOpts
 * @param {(google.maps.CircleOptions|Object.<string>)=} opt_circleOpts
 */

function GeolocationMarker(opt_map, opt_markerOpts, opt_circleOpts) {

  var markerOpts = {
    'clickable': false,
    'cursor': 'pointer',
    'draggable': false,
    'flat': true,
    'icon': new google.maps.MarkerImage(
        'https://google-maps-utility-library-v3.googlecode.com/svn/trunk/geolocationmarker/images/gpsloc.png',
        new google.maps.Size(34, 34),
        null,
        new google.maps.Point(8, 8),
        new google.maps.Size(17, 17)),

    // This marker may move frequently - don't force canvas tile redraw
    'optimized': false, 
    'position': new google.maps.LatLng(0, 0),
    'title': 'Current location',
    'zIndex': 2
  };

  if(opt_markerOpts) {
    markerOpts = this.copyOptions_(markerOpts, opt_markerOpts);
  }

  var circleOpts = {
    'clickable': false,
    'radius': 0,
    'strokeColor': '1bb6ff',
    'strokeOpacity': .4,
    'fillColor': '61a0bf',
    'fillOpacity': .4,
    'strokeWeight': 1,
    'zIndex': 1
  };

  if(opt_circleOpts) {
    circleOpts = this.copyOptions_(circleOpts, opt_circleOpts);
  }

  this.marker_ = new google.maps.Marker(markerOpts);
  this.circle_ = new google.maps.Circle(circleOpts);

  /**
   * @expose
   * @type {number?}
   */
  this.accuracy = null;

  /**
   * @expose
   * @type {google.maps.LatLng?}
   */
  this.position = null;

  /**
   * @expose
   * @type {google.maps.Map?}
   */
  this.map = null;
  
  this.set('minimum_accuracy', null);
  
  this.set('position_options', /** GeolocationPositionOptions */
      ({enableHighAccuracy: true, maximumAge: 1000}));

  this.circle_.bindTo('map', this.marker_);

  if(opt_map) {
    this.setMap(opt_map);
  }
}
GeolocationMarker.prototype = new google.maps.MVCObject;

/**
 * @override
 * @expose
 * @param {string} key
 * @param {*} value
 */
GeolocationMarker.prototype.set = function(key, value) {
  if (/^(?:position|accuracy)$/i.test(key)) {
    throw '\'' + key + '\' is a read-only property.';
  } else if (/map/i.test(key)) {
    this.setMap(/** @type {google.maps.Map} */ (value));
  } else {
    google.maps.MVCObject.prototype.set.apply(this, arguments);
  }
};

/**
 * @private
 * @type {google.maps.Marker}
 */
GeolocationMarker.prototype.marker_ = null;

/**
 * @private
 * @type {google.maps.Circle}
 */
GeolocationMarker.prototype.circle_ = null;

/** @return {google.maps.Map} */
GeolocationMarker.prototype.getMap = function() {
  return this.map;
};

/** @return {GeolocationPositionOptions} */
GeolocationMarker.prototype.getPositionOptions = function() {
  return /** @type GeolocationPositionOptions */(this.get('position_options'));
};

/** @param {GeolocationPositionOptions|Object.<string, *>} positionOpts */
GeolocationMarker.prototype.setPositionOptions = function(positionOpts) {
  this.set('position_options', positionOpts);
};

/** @return {google.maps.LatLng?} */
GeolocationMarker.prototype.getPosition = function() {
  return this.position;
};

/** @return {google.maps.LatLngBounds?} */
GeolocationMarker.prototype.getBounds = function() {
  if (this.position) {
    return this.circle_.getBounds();
  } else {
    return null;
  }
};

/** @return {number?} */
GeolocationMarker.prototype.getAccuracy = function() {
  return this.accuracy;
};

/** @return {number?} */
GeolocationMarker.prototype.getMinimumAccuracy = function() {
  return /** @type {number?} */ (this.get('minimum_accuracy'));
};

/** @param {number?} accuracy */
GeolocationMarker.prototype.setMinimumAccuracy = function(accuracy) {
  this.set('minimum_accuracy', accuracy);
};

/**
 * @private
 * @type {number}
 */
GeolocationMarker.prototype.watchId_ = -1;

/** @param {google.maps.Map} map */
GeolocationMarker.prototype.setMap = function(map) {
  this.map = map;
  this.notify('map');
  if (map) {
    this.watchPosition_();
  } else {
    this.marker_.unbind('position');
    this.circle_.unbind('center');
    this.circle_.unbind('radius');
    this.accuracy = null;
    this.position = null;
    navigator.geolocation.clearWatch(this.watchId_);
    this.watchId_ = -1;
    this.marker_.setMap(map);
  }
};

/** @param {google.maps.MarkerOptions|Object.<string>} markerOpts */
GeolocationMarker.prototype.setMarkerOptions = function(markerOpts) {
  this.marker_.setOptions(this.copyOptions_({}, markerOpts));
};

/** @param {google.maps.CircleOptions|Object.<string>} circleOpts */
GeolocationMarker.prototype.setCircleOptions = function(circleOpts) {
  this.circle_.setOptions(this.copyOptions_({}, circleOpts));
};

/**
 * @private 
 * @param {GeolocationPosition} position
 */
GeolocationMarker.prototype.updatePosition_ = function(position) {
  var newPosition = new google.maps.LatLng(position.coords.latitude,
      position.coords.longitude), mapNotSet = this.marker_.getMap() == null;

  if(mapNotSet) {
    if (this.getMinimumAccuracy() != null &&
        position.coords.accuracy > this.getMinimumAccuracy()) {
      return;
    }
    this.marker_.setMap(this.map);
    this.marker_.bindTo('position', this);
    this.circle_.bindTo('center', this, 'position');
    this.circle_.bindTo('radius', this, 'accuracy');
  }

  if (this.accuracy != position.coords.accuracy) {
    // The local set method does not allow accuracy to be updated
    google.maps.MVCObject.prototype.set.call(this, 'accuracy', position.coords.accuracy);
  }

  if (mapNotSet || this.position == null ||
      !this.position.equals(newPosition)) {
	// The local set method does not allow position to be updated
    google.maps.MVCObject.prototype.set.call(this, 'position', newPosition);
  }
};

/**
 * @private
 * @return {undefined}
 */
GeolocationMarker.prototype.watchPosition_ = function() {
  var self = this;

  if(navigator.geolocation) {
    this.watchId_ = navigator.geolocation.watchPosition(
        function(position) { self.updatePosition_(position); },
        function(e) { google.maps.event.trigger(self, "geolocation_error", e); },
        this.getPositionOptions());
  }
};

/**
 * @private
 * @param {Object.<string,*>} target
 * @param {Object.<string,*>} source
 * @return {Object.<string,*>}
 */
GeolocationMarker.prototype.copyOptions_ = function(target, source) {
  for(var opt in source) {
    if(GeolocationMarker.DISALLOWED_OPTIONS[opt] !== true) {
      target[opt] = source[opt];
    }
  }
  return target;
};

/**
 * @const
 * @type {Object.<string, boolean>}
 */
GeolocationMarker.DISALLOWED_OPTIONS = {
  'map': true,
  'position': true,
  'radius': true
};
(function() {

  $(function() {
    var GeoMarker, allRestaurants, displayRestaurants, getMarkerIcon, iw, latestSearch, map, oms, scaleMarkers, searchForRestaurants, showGeoMarker, timer;
    latestSearch = null;
    timer = null;
    allRestaurants = null;
    GeoMarker = null;
    getMarkerIcon = function(color) {
      return new google.maps.MarkerImage('http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|' + color, new google.maps.Size(21, 34), new google.maps.Point(0, 0), new google.maps.Point(10, 34));
    };
    displayRestaurants = function() {
      var content, i, marker, restaurant, _results;
      map.removeMarkers();
      i = 0;
      _results = [];
      while (i < restaurants.length) {
        restaurant = restaurants[i];
        content = '<div class="prehrana_info"><h4><a href="' + restaurant['link'] + '0" target="_blank">' + restaurant['name'] + '</a></h4>';
        content += '<address>' + restaurant['address'] + '</address>';
        content += '<p><strong>' + restaurant['price'] + '</strong></p>';
        content += '<ul>';
        content += '<li>Teden: ' + restaurant['opening']['Week'][0] + ' - ' + restaurant['opening']['Week'][1] + '</li>';
        if (restaurant['opening']['Saturday']) {
          content += '<li>Sobota: ' + restaurant['opening']['Saturday'][0] + ' - ' + restaurant['opening']['Saturday'][1] + '</li>';
        } else {
          content += '<li>Sobota: zaprto</li>';
        }
        if (restaurant['opening']['Sunday']) {
          content += '<li>Nedelja: ' + restaurant['opening']['Sunday'][0] + ' - ' + restaurant['opening']['Sunday'][1] + '</li>';
        } else {
          content += '<li>Nedelja: zaprto</li>';
        }
        if (restaurant['opening']['Notes']) {
          content += '<li>Opombe: ' + restaurant['opening']['Notes'] + '</li>';
        }
        content += '</ul></div>';
        marker = map.addMarker({
          lat: restaurant['coordinates'][0],
          lng: restaurant['coordinates'][1],
          title: restaurant['name'],
          icon: scaleMarkers[restaurant['price'][0]],
          content: content
        });
        oms.addMarker(marker);
        _results.push(i++);
      }
      return _results;
    };
    searchForRestaurants = function(search) {
      if (latestSearch !== search) {
        latestSearch = search;
        if (search === '' && (allRestaurants != null)) {
          window.restaurants = allRestaurants;
          return displayRestaurants();
        } else {
          return $.post('/search', {
            search: search
          }, (function(data) {
            window.restaurants = data;
            displayRestaurants();
            if (search === '') {
              return allRestaurants = data;
            }
          }), 'json');
        }
      }
    };
    showGeoMarker = function() {
      GeoMarker = new GeolocationMarker(map.map);
      GeoMarker.setMinimumAccuracy(100);
      return google.maps.event.addListenerOnce(GeoMarker, 'position_changed', function() {
        map.setZoom(15);
        map.panTo(this.getPosition());
        return $('#geolocateIcon').show();
      });
    };
    map = new GMaps({
      div: '#map',
      lat: 46.119944,
      lng: 14.815333,
      zoom: 8,
      disableDefaultUI: true
    });
    oms = new OverlappingMarkerSpiderfier(map.map, {
      keepSpiderfied: true,
      markersWontMove: true,
      markersWontHide: true
    });
    iw = new google.maps.InfoWindow();
    oms.addListener('click', function(marker) {
      iw.setContent(marker.content);
      return iw.open(map.map, marker);
    });
    scaleMarkers = [getMarkerIcon('ffe7c8'), getMarkerIcon('ffcc95'), getMarkerIcon('ffad60'), getMarkerIcon('ff8c1f'), getMarkerIcon('e04f00')];
    searchForRestaurants('');
    if (navigator.geolocation) {
      showGeoMarker();
    }
    $('#geolocateIcon').on('click', function(event) {
      event.preventDefault();
      return map.panTo(GeoMarker.getPosition());
    });
    return $('#restaurantSearch').on('keyup', function() {
      var search;
      clearTimeout(timer);
      search = $(this).val();
      return timer = setTimeout(function() {
        return searchForRestaurants(search);
      }, 500);
    });
  });

}).call(this);
