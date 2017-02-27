module ProMotion
  module MapScreenModule

    PIN_COLORS = {
      red: MKPinAnnotationColorRed,
      green: MKPinAnnotationColorGreen,
      purple: MKPinAnnotationColorPurple
    }

    def screen_setup
      self.view = nil
      self.view = MGLMapView.alloc.initWithFrame(self.view.bounds, styleURL: self.class.get_map_style)
      self.view.delegate = self

      check_annotation_data
      @promotion_annotation_data = []
      set_up_start_position
      set_up_tap_to_add
    end

    def on_appear
      update_annotation_data
    end

    def check_annotation_data
      mp "Missing #annotation_data method in MapScreen #{self.class.to_s}.", force_color: :red unless self.respond_to?(:annotation_data)
    end

    def update_annotation_data
      clear_annotations
      add_annotations annotation_data
    end

    def map
      self.view
    end
    alias_method :mapview, :map

    def center
      self.view.centerCoordinate
    end

    def center=(params={})
      mp "Missing #:latitude property in call to #center=.", force_color: :red unless params[:latitude]
      mp "Missing #:longitude property in call to #center=.", force_color: :red unless params[:longitude]
      params[:animated] ||= true

      # Set the new region
      self.view.setCenterCoordinate(
        CLLocationCoordinate2D.new(params[:latitude], params[:longitude]),
        animated:params[:animated]
      )
    end

    def show_user_location
      if location_manager.respondsToSelector('requestWhenInUseAuthorization')
        location_manager.requestWhenInUseAuthorization
      end

      set_show_user_location true
    end

    def hide_user_location
      set_show_user_location false
    end

    def set_show_user_location(show,mode=MGLUserTrackingModeFollow)
      self.view.showsUserLocation = show
      self.view.userTrackingMode = mode
    end

    def showing_user_location?
      self.view.showsUserLocation
    end

    def track_user_location params={}
      params = {heading: false}.merge(params)
      set_track_user_location params[:heading]
    end

    def set_track_user_location heading
      self.view.userTrackingMode = heading ? MKUserTrackingModeFollowWithHeading : MKUserTrackingModeFollow
    end

    def user_location
      user_annotation.nil? ? nil : user_annotation.coordinate
    end

    def user_annotation
      self.view.userLocation.location.nil? ? nil : self.view.userLocation.location
    end

    def zoom_to_user(radius = 0.05, animated=true)
      show_user_location unless showing_user_location?
      set_region(create_region(user_location,radius), animated)
    end

    def annotations
      @promotion_annotation_data
    end

    def select_annotation(annotation, animated=true)
      self.view.selectAnnotation(annotation, animated:animated)
    end

    def select_annotation_at(annotation_index, animated=true)
      select_annotation(annotations[annotation_index], animated:animated)
    end

    def selected_annotations
      self.view.selectedAnnotations
    end

    def deselect_annotations(animated=false)
      unless selected_annotations.nil?
        selected_annotations.each do |annotation|
          self.view.deselectAnnotation(annotation, animated:animated)
        end
      end
    end

    def add_annotation(annotation)
      @promotion_annotation_data << MapScreenAnnotation.new(annotation)
      self.view.addAnnotation @promotion_annotation_data.last
    end

    def add_annotations(annotations)
      @promotion_annotation_data = Array(annotations).map{|a| MapScreenAnnotation.new(a)}
      self.view.addAnnotations @promotion_annotation_data
    end

    def clear_annotation(annotation)
      self.view.removeAnnotation(annotation)
      @promotion_annotation_data.delete(annotation)
    end

    def clear_annotations
      self.view.removeAnnotations(@promotion_annotation_data)
      @promotion_annotation_data = []
    end

    def set_start_position(params={})
      params = {
        latitude: 37.331789,
        longitude: -122.029620,
        radius: 10
      }.merge(params)

      initialLocation = CLLocationCoordinate2D.new(params[:latitude], params[:longitude])
      region = create_region(initialLocation,params[:radius])
      set_region(region, animated:false)
    end

    def set_up_start_position
      if self.class.respond_to?(:get_start_position) && self.class.get_start_position
        self.set_start_position self.class.get_start_position_params
      end
    end

    def set_tap_to_add(params={})
      params = {
        length: 2.0,
        target: self,
        action: "gesture_drop_pin:",
        annotation: {
          title: "Dropped Pin",
          animates_drop: true
        }
      }.merge(params)
      @tap_to_add_annotation_params = params[:annotation]

      lpgr = UILongPressGestureRecognizer.alloc.initWithTarget(params[:target], action:params[:action])
      lpgr.minimumPressDuration = params[:length]
      self.view.addGestureRecognizer(lpgr)
    end

    def gesture_drop_pin(gesture_recognizer)
      if gesture_recognizer.state == UIGestureRecognizerStateBegan
        NSNotificationCenter.defaultCenter.postNotificationName("ProMotionMapWillAddPin", object:nil)
        touch_point = gesture_recognizer.locationInView(self.view)
        touch_map_coordinate = self.view.convertPoint(touch_point, toCoordinateFromView:self.view)

        add_annotation({
          coordinate: touch_map_coordinate
        }.merge(@tap_to_add_annotation_params))
        NSNotificationCenter.defaultCenter.postNotificationName("ProMotionMapAddedPin", object:@promotion_annotation_data.last)
      end
    end

    def set_up_tap_to_add
      if self.class.respond_to?(:get_tap_to_add) && self.class.get_tap_to_add
        self.set_tap_to_add self.class.get_tap_to_add_params
      end
    end

    # TODO: Why is this so complex?
    def zoom_to_fit_annotations(args={})
      # Preserve backwards compatibility
      args = {animated: args} if args == true || args == false
      args = {animated: true, include_user: false}.merge(args)

      ann = args[:include_user] ? (annotations + [user_annotation]).compact : annotations

      #Don't attempt the rezoom of there are no pins
      return if ann.count == 0

      #Set some crazy boundaries
      topLeft = CLLocationCoordinate2D.new(-90, 180)
      bottomRight = CLLocationCoordinate2D.new(90, -180)

      #Find the bounds of the pins
      ann.each do |a|
        topLeft.longitude = [topLeft.longitude, a.coordinate.longitude].min
        topLeft.latitude = [topLeft.latitude, a.coordinate.latitude].max
        bottomRight.longitude = [bottomRight.longitude, a.coordinate.longitude].max
        bottomRight.latitude = [bottomRight.latitude, a.coordinate.latitude].min
      end

      #Find the bounds of all the pins and set the map_view
      coord = CLLocationCoordinate2D.new(
        topLeft.latitude - (topLeft.latitude - bottomRight.latitude) * 0.5,
        topLeft.longitude + (bottomRight.longitude - topLeft.longitude) * 0.5
      )

      # Add some padding to the edges
      span = MKCoordinateSpanMake(
        ((topLeft.latitude - bottomRight.latitude) * 1.075).abs,
        ((bottomRight.longitude - topLeft.longitude) * 1.075).abs
      )

      region = MKCoordinateRegionMake(coord, span)
      fits = self.view.regionThatFits(region)

      set_region(fits, animated: args[:animated])
    end

    def set_region(region, animated=true)
      self.view.setVisibleCoordinateBounds(
        [region[:southWest], region[:northEast]],
        animated: animated
      )
    end

    ###### REGION SETTINGS #######
    def deg_to_rad(angle)
      angle*Math::PI/180
    end

    def rad_to_deg(angle)
      angle*180/Math::PI
    end

    # Input coordinates and bearing in decimal degrees, distance in kilometers
    def point_from_location_bearing_and_distance(initialLocation, bearing, distance)
      distance = distance / 6371.01 # Convert to angular radians dividing by the Earth radius
      bearing = deg_to_rad(bearing)
      input_latitude = deg_to_rad(initialLocation.latitude)
      input_longitude = deg_to_rad(initialLocation.longitude)

      output_latitude = Math.asin( 
                          Math.sin(input_latitude) * Math.cos(distance) + 
                          Math.cos(input_latitude) * Math.sin(distance) * 
                          Math.cos(bearing)
                        )

      dlon = input_longitude + Math.atan2(
                                Math.sin(bearing) * Math.sin(distance) * 
                                Math.cos(input_longitude), Math.cos(distance) - 
                                Math.sin(input_longitude) * Math.sin(output_latitude)
                              )

      output_longitude = (dlon + 3*Math::PI) % (2*Math::PI) - Math::PI  
      CLLocationCoordinate2DMake(rad_to_deg(output_latitude), rad_to_deg(output_longitude))
    end

    def create_region(initialLocation,radius=10)
      return nil unless initialLocation.is_a? CLLocationCoordinate2D
      radius = radius * 1.820 # Meters equivalent to 1 Nautical Mile
      southWest = self.point_from_location_bearing_and_distance(initialLocation,225, radius)
      northEast = self.point_from_location_bearing_and_distance(initialLocation,45, radius)
      {:southWest => southWest, :northEast => northEast}
    end
    alias_method :region, :create_region

    ##### END REGION SETTINGS ######
    ##### MAP STYLE SETTINGS  ######
    def set_map_style
      if self.class.respond_to?(:get_map_style)
          self.view.styleURL = self.class.get_map_style
      end
    end
    ##### END MAP STYLE SETTINGS  ######


    def look_up_address(args={}, &callback)
      args[:address] = args if args.is_a? String # Assume if a string is passed that they want an address

      geocoder = CLGeocoder.new
      return geocoder.geocodeAddressDictionary(args[:address], completionHandler: callback) if args[:address].is_a?(Hash)
      return geocoder.geocodeAddressString(args[:address].to_s, completionHandler: callback) unless args[:region]
      return geocoder.geocodeAddressString(args[:address].to_s, inRegion:args[:region].to_s, completionHandler: callback) if args[:region]
    end

    def look_up_location(location, &callback)
      location = CLLocation.alloc.initWithLatitude(location.latitude, longitude:location.longitude) if location.is_a?(CLLocationCoordinate2D)

      if location.kind_of?(CLLocation)
        geocoder = CLGeocoder.new
        geocoder.reverseGeocodeLocation(location, completionHandler: callback)
      else
        mp "You're trying to reverse geocode something that isn't a CLLocation", force_color: :green
        callback.call nil, nil
      end
    end

    ########## Mapbox GL methods #################
    def mapView(mapView, annotationCanShowCallout: annotation)
      return nil if annotation.is_a? MGLUserLocation
      annotation.params[:show_callout]
    end

    def mapView(mapView, imageForAnnotation: annotation)
      return nil unless annotation.params[:image]
      annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier(annotation.params[:image])
      if !annotationImage
        image = UIImage.imageNamed(annotation.params[:image])
        annotationImage = MGLAnnotationImage.annotationImageWithImage(image, reuseIdentifier: annotation.params[:image])
        return annotationImage
      end
    end

    def mapView(mapview, leftCalloutAccessoryViewForAnnotation: annotation)
      if annotation.params[:left_action]
        button_type = annotation.params[:left_action_button_type] || UIButtonTypeDetailDisclosure
        action_button = UIButton.buttonWithType(button_type)

        action_button
      else
        annotation.left_accessory
      end
    end

    def mapView(mapview, rightCalloutAccessoryViewForAnnotation: annotation)
      if annotation.params[:right_action]
        button_type = annotation.params[:right_action_button_type] || UIButtonTypeDetailDisclosure
        action_button = UIButton.buttonWithType(button_type)
        action_button.tag = 1

        action_button
      else
        annotation.right_accessory
      end
    end

    def mapView(mapView, annotation: annotation, calloutAccessoryControlTapped: accessory)
      return nil unless annotation.params[:left_action] || annotation.params[:right_action]
      if accessory.tag == 1
        self.send(annotation.params[:right_action])
      else
        self.send(annotation.params[:left_action])
      end
    end

    ########## Cocoa touch methods #################
    def mapView(map_view, didUpdateUserLocation:userLocation)
      if self.respond_to?(:on_user_location)
        on_user_location(userLocation)
      else
        mp "You're tracking the user's location but have not implemented the #on_user_location(location) method in MapScreen #{self.class.to_s}.", force_color: :green
      end
    end

    def mapView(map_view, regionWillChangeAnimated:animated)
      if self.respond_to?("will_change_region:")
        will_change_region(animated)
      elsif self.respond_to?(:will_change_region)
        will_change_region
      end
    end

    def mapView(map_view, regionDidChangeAnimated:animated)
      if self.respond_to?("on_change_region:")
        on_change_region(animated)
      elsif self.respond_to?(:on_change_region)
        on_change_region
      end
    end

    ########## Cocoa touch Ruby counterparts #################

    def type
      map.mapType
    end

    def type=(type)
      map.mapType = type
    end

    %w(zoom scroll pitch rotate).each do |meth|
      define_method("#{meth}_enabled?") do
        map.send("is#{meth.capitalize}Enabled")
      end

      define_method("#{meth}_enabled=") do |argument|
        map.send("#{meth}Enabled=", argument)
      end
    end

    module MapClassMethods
      # Start Position
      def start_position(params={})
        @start_position_params = params
        @start_position = true
      end

      def get_start_position_params
        @start_position_params ||= nil
      end

      def get_start_position
        @start_position ||= false
      end

      # Tap to drop pin
      def tap_to_add(params={})
        @tap_to_add_params = params
        @tap_to_add = true
      end

      def get_tap_to_add_params
        @tap_to_add_params ||= nil
      end

      def get_tap_to_add
        @tap_to_add ||= false
      end

      def map_style(style)
        @map_style_url = NSURL.URLWithString("asset://styles/#{style}.json")
      end

      def get_map_style
        @map_style_url ||= map_style(:light)
      end


    end
    def self.included(base)
      base.extend(MapClassMethods)
    end

    private

    def location_manager
      @location_manager ||= CLLocationManager.alloc.init
      @location_manager.delegate ||= self
      @location_manager
    end

  end
end
