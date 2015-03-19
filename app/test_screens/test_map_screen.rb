class TestMapScreen < PM::MapScreen
  attr_accessor :infinite_loop_points, :request_complete, :action_called
  attr_accessor :got_region_will_change, :got_region_did_change

  start_position latitude: 35.090648651123, longitude: -82.965972900391, radius: 4
  title "Gorges State Park, NC"
  tap_to_add length: 1.5, annotation: {animates_drop: false, title: "A new park?"}

  def on_load
    @action_called = false
    @got_region_did_change = false
    @got_region_will_change = false
  end

  def promotion_annotation_data
    @promotion_annotation_data
  end

  def annotation_data
    # Partial set of data from "GPS Map of Gorges State Park": http://www.hikewnc.info/maps/gorges-state-park/gps-map
    @data ||= [{
      longitude: -82.965972900391,
      latitude: 35.090648651123,
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest",
    },{
      # Example of using :coordinate instead of :latitude & :longitude
      coordinate: CLLocationCoordinate2DMake(35.092520895652, -82.966093558105),
      title: "Turtleback Falls",
      subtitle: "Nantahala National Forest",
    },{
      longitude: -82.95916,
      latitude: 35.07496,
      title: "Windy Falls"
    },{
      longitude: -82.943031505056,
      latitude: 35.102516828489,
      title: "Upper Bearwallow Falls",
      subtitle: "Gorges State Park",
    },{
      longitude: -82.956244328014,
      latitude: 35.085548421623,
      title: "Stairway Falls",
      subtitle: "Gorges State Park",
    }]
  end

  def lookup_infinite_loop
    self.request_complete = false
    self.look_up_address address: "1 Infinite Loop" do |points, error|
      self.request_complete = true
      self.infinite_loop_points = points
    end
  end

  def my_action
    @action_called = true
  end

  def region_will_change
    @got_region_will_change = true
  end

  def region_did_change
    @got_region_did_change = true
  end

end
