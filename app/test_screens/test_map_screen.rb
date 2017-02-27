class TestMapScreen < PM::MapScreen
  attr_accessor :infinite_loop_points, :request_complete, :action_called
  attr_accessor :got_will_change_region, :got_on_change_region

  start_position latitude: -22.969368, longitude: -43.179837, radius: 10
  title "Rio de Janeiro, Brasil"
  map_style "mapbox-streets-v7"
  tap_to_add length: 1.5, annotation: {animates_drop: false, title: "A new park?"}

  def on_load
    @action_called = false
    @got_will_change_region = false
    @got_on_change_region = false
  end

  def promotion_annotation_data
    @promotion_annotation_data
  end

  def annotation_data
    # Partial set of data from "GPS Map of Gorges State Park": http://www.hikewnc.info/maps/gorges-state-park/gps-map
    @data ||= [{
      # Example of using :coordinate instead of :latitude & :longitude
      coordinate: CLLocationCoordinate2DMake(-22.969368, -43.179837),
      title: "Praia de Copacabana",
      subtitle: "Rio de Janeiro",
      left_accessory: UIButton.buttonWithType(3),
    },{
      longitude: -43.285188,
      latitude: -22.945641,
      title: "Floresta da Tijuca",
      subtitle: "Floresta Nacional da Tijuca",
      image: "park2",
      left_action: :my_action
    },{
      longitude: -43.156084,
      latitude: -22.949318,
      title: "Pão de Açucar",
      subtitle: "Sugar Loaf",
      right_action: :my_action,
    },{
      longitude: -43.175977,
      latitude: -22.909438,
      title: "Teatro Municipal",
    },{
      longitude: -43.179191,
      latitude: -22.915285,
      title: "Escadaria Selaron",
      subtitle: "Lapa",
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

  def will_change_region
    @got_will_change_region = true
  end

  def on_change_region
    @got_on_change_region = true
  end

end
