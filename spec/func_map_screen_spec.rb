describe "ProMotion::TestMapScreen functionality" do
  tests TestMapScreen

  def map_screen
    @map_screen ||= TestMapScreen.new(nav_bar: true)
  end

  def controller
    map_screen.navigationController
  end

  def default_annotation
    {
      coordinate: CLLocationCoordinate2DMake(-22.969368, -43.179837),
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle"
    }
  end

  def add_image_annotation
    ann = default_annotation.merge({
      image: "park2"
    })
    map_screen.annotations.count.should == 5
    map_screen.add_annotation ann
    map_screen.annotations.count.should == 6
    #map_screen.set_region map_screen.region(map_screen.annotations.last.coordinate, 10)
  end

  after do
    map_screen = nil
  end

  it "should have a navigation bar" do
    map_screen.navigationController.should.be.kind_of(UINavigationController)
  end

  it "should start the map in the correct location" do
    center_coordinate = map_screen.center
    center_coordinate.latitude.should.be.close -22.969368, 0.02
    center_coordinate.longitude.should.be.close -43.179837, 0.02
  end

  it "should move the map center" do
    map_screen.center = {latitude: -22.969468, longitude: -43.223525, animated: true}

    wait 0.75 do
      center_coordinate = map_screen.center
      center_coordinate.latitude.should.be.close -22.969468, 0.02
      center_coordinate.longitude.should.be.close -43.223525, 0.02
    end
  end

  it "should select an annotation" do
    map_screen.selected_annotations.should == []
    map_screen.center = {latitude: map_screen.annotations.first.coordinate.latitude,
      longitude: map_screen.annotations.first.coordinate.longitude, animated: false
    }
    wait 0.75 do
      map_screen.select_annotation map_screen.annotations.first, false
      wait 0.75 do
        map_screen.selected_annotations.count.should == 1
      end
    end
  end

  it "should select an annotation by index" do
    map_screen.deselect_annotations
    map_screen.selected_annotations.should == []
    map_screen.center = {latitude: map_screen.annotations[2].coordinate.latitude,
      longitude: map_screen.annotations[2].coordinate.longitude, animated: false
    }
    wait 0.75 do
      map_screen.select_annotation_at 2
      wait 0.75 do
        map_screen.selected_annotations.count.should == 1
        map_screen.selected_annotations[0].should == map_screen.annotations[2]
      end
    end
  end

  it "should select another annotation and check that the title is correct" do
    map_screen.deselect_annotations
    map_screen.selected_annotations.should == []
    map_screen.center = {latitude: map_screen.annotations[0].coordinate.latitude,
      longitude: map_screen.annotations[0].coordinate.longitude, animated: false
    }
    wait 0.75 do
      map_screen.select_annotation map_screen.annotations.first
      wait 0.75 do
        map_screen.selected_annotations.count.should == 1
        map_screen.selected_annotations.first.title.should == "Praia de Copacabana"
        map_screen.selected_annotations.first.subtitle.should == "Rio de Janeiro"
      end
    end
  end

  it "should deselect selected annotations" do
    map_screen.select_annotation map_screen.annotations.last

    map_screen.deselect_annotations
    wait 0.75 do
      map_screen.selected_annotations.should == []
    end
  end

  it "should add an annotation and be able to zoom immediately" do
    ann = {
      longitude: -43.179837,
      latitude: -22.969368,
      title: "Something Else"
    }
    map_screen.annotations.count.should == 5
    map_screen.add_annotation ann
    map_screen.annotations.count.should == 6
    map_screen.set_region map_screen.region(map_screen.annotations.last.coordinate, 10)
    map_screen.select_annotation map_screen.annotations.last
  end

  it "should be able to overwrite all annotations" do
    anns = [{
      longitude: -43.279837,
      latitude: -22.869368,
      title: "My Cool Pin"
    },{
      longitude: -43.379837 ,
      latitude: -22.769368,
      title: "My Cool Pin"
    }]
    map_screen.annotations.count.should == 5
    map_screen.add_annotations anns
    map_screen.annotations.count.should == 2
  end

  it "should add an image based annotation" do
    add_image_annotation
    map_screen.annotations.count.should == 6
    checking = map_screen.annotations.last
    %w(title subtitle coordinate).each do |method|
      defined?(checking.send(method.to_sym)).nil?.should.be.false
    end
  end

  it "should select an image annotation" do
    add_image_annotation
    map_screen.selected_annotations.should == []
    map_screen.center = {latitude: map_screen.annotations.last.coordinate.latitude,
      longitude: map_screen.annotations.last.coordinate.longitude, animated: false
    }
    wait 0.75 do
      map_screen.select_annotation map_screen.annotations.last, false
      wait 1.75 do
        map_screen.selected_annotations.count.should == 1
      end
    end
  end

  it "should select an image annotation by index" do
    map_screen.deselect_annotations
    add_image_annotation
    map_screen.selected_annotations.should == []
    map_screen.select_annotation_at 5, false
    map_screen.selected_annotations.count.should == 1
    map_screen.selected_annotations[0].should == map_screen.annotations[5]
  end

  it "should select an image annotation and check that the title is correct" do
    #map_screen.deselect_annotations
    add_image_annotation
    map_screen.selected_annotations.should == []
    map_screen.select_annotation map_screen.annotations[5]
    map_screen.selected_annotations.count.should == 1
    map_screen.selected_annotations.first.title.should == "My Cool Image Pin"
    map_screen.selected_annotations.first.subtitle.should == "Image pin subtitle"
  end

  it "should allow setting a leftCalloutAccessoryView" do
    btn = UIButton.new
    ann = {
      longitude: -22.969368,
      latitude: -43.179837,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle",
      left_accessory: btn
    }
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    map_screen.mapView(map_screen.view, leftCalloutAccessoryViewForAnnotation: annot).is_a?(UIButton).should == true
  end

  it "should allow setting a rightCalloutAccessoryView" do
    btn = UIButton.new
    ann = {
      longitude: -22.968368,
      latitude: -43.179737,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle",
      right_accessory: btn
    }
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    map_screen.mapView(map_screen.view, rightCalloutAccessoryViewForAnnotation: annot).is_a?(UIButton).should == true
  end

  it "should call the correct action when set on an annotation" do
    ann = default_annotation.merge({
      right_action: :my_action
    })
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    accessory = map_screen.mapView(map_screen.view, rightCalloutAccessoryViewForAnnotation: annot)
    accessory.is_a?(UIButton).should == true
    accessory.buttonType.should == UIButtonTypeDetailDisclosure

    map_screen.action_called.should == false
    map_screen.send(annot.params[:right_action])
    map_screen.action_called.should == true
  end

  it "should allow a user to set an action with a custom button type" do
    ann = default_annotation.merge({
      left_action: :my_action_with_sender,
      left_action_button_type: UIButtonTypeContactAdd
    })
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    accessory = map_screen.mapView(map_screen.view, leftCalloutAccessoryViewForAnnotation: annot)

    accessory.class.should == UIButton
    accessory.buttonType.should == UIButtonTypeContactAdd
  end

  it 'should allow you to set different properties of MKMapView' do
    map_screen.map.styleURL.class.should == NSURL
    map_screen.map.setStyleURL map_screen.map.bundledStyleURLs[1]
    map_screen.map.styleURL.should == map_screen.map.bundledStyleURLs[1]

    map_screen.map.isZoomEnabled.should == true
    map_screen.map.zoomEnabled = false
    map_screen.map.isZoomEnabled.should == false

    map_screen.map.isRotateEnabled.should == true
    map_screen.map.rotateEnabled = false
    map_screen.map.isRotateEnabled.should == false
  end

  it "can lookup a location with a CLLocation" do
    location = CLLocation.alloc.initWithLatitude(-34.226082, longitude: 150.668374)

    map_screen.look_up_location(location) do |placemarks, fetch_error|
      @error = fetch_error
      @placemark = placemarks.first
      resume
    end

    wait do
      @error.should == nil
      @placemark.should.be.kind_of?(CLPlacemark)
      @error = nil
      @placemark = nil
    end
  end

  it "can lookup a location with a CLLocationCoordinate2D" do
    location = CLLocationCoordinate2DMake(-34.226082, 150.668374)

    map_screen.look_up_location(location) do |placemarks, fetch_error|
      @error = fetch_error
      @placemark = placemarks.first
      resume
    end

    wait do
      @error.should == nil
      @placemark.should.be.kind_of?(CLPlacemark)
      @error = nil
      @placemark = nil
    end
  end

  it "should call will_change_region" do
    map_screen.on_load
    map_screen.got_will_change_region.should == false
    map_screen.mapView(map_screen.map, regionWillChangeAnimated: true)
    map_screen.got_will_change_region.should == true
  end

  it "should call on_change_region" do
    map_screen.on_load
    map_screen.got_on_change_region.should == false
    map_screen.mapView(map_screen.map, regionDidChangeAnimated: true)
    map_screen.got_on_change_region.should == true
  end
end
