module ProMotion
  module MapScreenModule

    def screen_setup
      self.view = nil
      self.view = MKMapView.alloc.initWithFrame(self.view.bounds)
      self.view.delegate = self

      check_annotation_data
      @promotion_annotation_data = []
      set_up_start_position
      set_up_tap_to_add
    end

    def view_will_appear(animated)
      super
      update_annotation_data
    end

    def check_annotation_data
      PM.logger.error "Missing #annotation_data method in MapScreen #{self.class.to_s}." unless self.respond_to?(:annotation_data)
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
      PM.logger.error "Missing #:latitude property in call to #center=." unless params[:latitude]
      PM.logger.error "Missing #:longitude property in call to #center=." unless params[:longitude]
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

    def set_show_user_location(show)
      self.view.showsUserLocation = show
    end

    def showing_user_location?
      self.view.showsUserLocation
    end

    def user_location
      user_annotation.nil? ? nil : user_annotation.coordinate
    end

    def user_annotation
      self.view.userLocation.location.nil? ? nil : self.view.userLocation.location
    end

    def zoom_to_user(radius = 0.05, animated=true)
      show_user_location unless showing_user_location?
      set_region(MKCoordinateRegionMake(user_location, [radius, radius]), animated)
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

    def clear_annotations
      @promotion_annotation_data.each do |a|
        self.view.removeAnnotation(a)
      end
      @promotion_annotation_data = []
    end

    def annotation_view(map_view, annotation)
      return if annotation.is_a? MKUserLocation

      params = annotation.params

      identifier = params[:identifier]
      if view = map_view.dequeueReusableAnnotationViewWithIdentifier(identifier)
        view.annotation = annotation
      else
        # Set the pin properties
        if params[:image]
          view = MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        else
          view = MKPinAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:identifier)
        end
      end
      view.image = params[:image] if view.respond_to?("image=") && params[:image]
      view.animatesDrop = params[:animates_drop] if view.respond_to?("animatesDrop=")
      view.pinColor = params[:pin_color] if view.respond_to?("pinColor=")
      view.canShowCallout = params[:show_callout] if view.respond_to?("canShowCallout=")

      if params[:left_accessory]
        view.leftCalloutAccessoryView = params[:left_accessory]
      end
      if params[:right_accessory]
        view.rightCalloutAccessoryView = params[:right_accessory]
      end

      if params[:action]
        button_type = params[:action_button_type] || UIButtonTypeDetailDisclosure

        action_button = UIButton.buttonWithType(button_type)
        action_button.addTarget(self, action: params[:action], forControlEvents:UIControlEventTouchUpInside)

        view.rightCalloutAccessoryView = action_button
      end
      view
    end

    def set_start_position(params={})
      params = {
        latitude: 37.331789,
        longitude: -122.029620,
        radius: 10
      }.merge(params)

      meters_per_mile = 1609.344

      initialLocation = CLLocationCoordinate2D.new(params[:latitude], params[:longitude])
      region = MKCoordinateRegionMakeWithDistance(initialLocation, params[:radius] * meters_per_mile, params[:radius] * meters_per_mile)
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
        action: "gesture_drop_pin:"
      }.merge(params)

      @tap_to_add_annotation_params = {
        title: "Dropped Pin",
        animates_drop: true
      }.merge(params[:annotation] || {})

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
      self.view.setRegion(region, animated:animated)
    end

    def region(params)
      return nil unless params.is_a? Hash

      params[:coordinate] = CLLocationCoordinate2D.new(params[:coordinate][:latitude], params[:coordinate][:longitude]) if params[:coordinate].is_a? Hash
      params[:span] = MKCoordinateSpanMake(params[:span][0], params[:span][1]) if params[:span].is_a? Array

      if params[:coordinate] && params[:span]
        MKCoordinateRegionMake( params[:coordinate], params[:span] )
      end
    end

    def look_up_address(args={}, &callback)
      args[:address] = args if args.is_a? String # Assume if a string is passed that they want an address

      geocoder = CLGeocoder.new
      return geocoder.geocodeAddressDictionary(args[:address], completionHandler: callback) if args[:address].is_a?(Hash)
      return geocoder.geocodeAddressString(args[:address].to_s, completionHandler: callback) unless args[:region]
      return geocoder.geocodeAddressString(args[:address].to_s, inRegion:args[:region].to_s, completionHandler: callback) if args[:region]
    end

    ########## Cocoa touch methods #################
    def mapView(map_view, viewForAnnotation:annotation)
      annotation_view(map_view, annotation)
    end

    def mapView(map_view, didUpdateUserLocation:userLocation)
      if self.respond_to?(:on_user_location)
        on_user_location(userLocation)
      else
        PM.logger.info "You're tracking the user's location but have not implemented the #on_user_location(location) method in MapScreen #{self.class.to_s}."
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
