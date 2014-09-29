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
      longitude: -82.965972900392,
      latitude: 35.090648651124,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle"
    }
  end

  def add_image_annotation
    ann = default_annotation.merge({
      image: UIImage.imageNamed("test.png")
    })
    map_screen.annotations.count.should == 5
    map_screen.add_annotation ann
    map_screen.set_region map_screen.region(coordinate: map_screen.annotations.last.coordinate, span: [0.05, 0.05])
  end

  after do
    map_screen = nil
  end

  it "should have a navigation bar" do
    map_screen.navigationController.should.be.kind_of(UINavigationController)
  end

  it "should have the map properly centered" do
    center_coordinate = map_screen.center
    center_coordinate.latitude.should.be.close 35.090648651123, 0.02
    center_coordinate.longitude.should.be.close -82.965972900391, 0.02
  end

  it "should move the map center" do
    map_screen.center = {latitude: 35.07496, longitude: -82.95916, animated: true}

    wait 0.75 do
      center_coordinate = map_screen.center
      center_coordinate.latitude.should.be.close 35.07496, 0.001
      center_coordinate.longitude.should.be.close -82.95916, 0.001
    end
  end

  it "should select an annotation" do
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation map_screen.annotations.first
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
    end
  end

  it "should select an annotation by index" do
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation_at 2
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
      map_screen.selected_annotations[0].should == map_screen.promotion_annotation_data[2]
    end
  end

  it "should select another annotation and check that the title is correct" do
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation map_screen.annotations[1]
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
    end

    map_screen.selected_annotations.first.title.should == "Turtleback Falls"
    map_screen.selected_annotations.first.subtitle.should == "Nantahala National Forest"

  end

  it "should deselect selected annotations" do
    map_screen.select_annotation map_screen.annotations.last
    wait 0.75 do
      # map_screen.selected_annotations.count.should == 1
    end

    map_screen.deselect_annotations
    wait 0.75 do
      map_screen.selected_annotations.should == nil
    end
  end

  it "should add an annotation and be able to zoom immediately" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Something Else"
    }
    map_screen.annotations.count.should == 5
    map_screen.add_annotation ann
    map_screen.annotations.count.should == 6
    map_screen.set_region map_screen.region(coordinate: map_screen.annotations.last.coordinate, span: [0.05, 0.05])
    map_screen.select_annotation map_screen.annotations.last
  end

  it "should be able to overwrite all annotations" do
    anns = [{
      longitude: -122.029620,
      latitude: 37.331789,
      title: "My Cool Pin"
    },{
      longitude: -80.8498118 ,
      latitude: 35.2187218,
      title: "My Cool Pin"
    }]
    map_screen.annotations.count.should == 5
    map_screen.add_annotations anns
    map_screen.annotations.count.should == 2
  end

  it "should add an image based annotation" do
    add_image_annotation
    map_screen.annotations.count.should == 6

    # Checking that it conforms to the MKAnnotation protocol manually since this doesn't work in iOS 7:
    #  map_screen.annotations.last.conformsToProtocol(MKAnnotation).should.be.true
    # See this 8 month old bug - https://github.com/siuying/rubymotion-protocol-bug

    checking = map_screen.annotations.last
    %w(title subtitle coordinate).each do |method|
      defined?(checking.send(method.to_sym)).nil?.should.be.false
    end
  end

  it "should select an image annotation" do
    add_image_annotation
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation map_screen.annotations.last
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
    end
  end

  it "should select an image annotation by index" do
    add_image_annotation
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation_at 5
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
      map_screen.selected_annotations[0].should == map_screen.promotion_annotation_data[5]
    end
  end

  it "should select an image annotation and check that the title is correct" do
    add_image_annotation
    map_screen.selected_annotations.should == nil
    map_screen.select_annotation map_screen.annotations[5]
    wait 0.75 do
      map_screen.selected_annotations.count.should == 1
    end
    map_screen.selected_annotations.first.title.should == "My Cool Image Pin"
    map_screen.selected_annotations.first.subtitle.should == "Image pin subtitle"
  end

  it "should allow setting a leftCalloutAccessoryView" do
    btn = UIButton.new
    ann = {
      longitude: -82.965972900392,
      latitude: 35.090648651124,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle",
      left_accessory: btn
    }
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    v = map_screen.annotation_view(map_screen.view, annot)
    v.leftCalloutAccessoryView.should == btn
  end

  it "should allow setting a rightCalloutAccessoryView" do
    btn = UIButton.new
    ann = {
      longitude: -82.965972900392,
      latitude: 35.090648651124,
      title: "My Cool Image Pin",
      subtitle: "Image pin subtitle",
      right_accessory: btn
    }
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    v = map_screen.annotation_view(map_screen.view, annot)
    v.rightCalloutAccessoryView.should == btn
  end

  it "should call the correct action when set on an annotation" do
    ann = default_annotation.merge({
      action: :my_action
    })
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    v = map_screen.annotation_view(map_screen.mapview, annot)

    v.rightCalloutAccessoryView.class.should == UIButton
    v.rightCalloutAccessoryView.buttonType.should == UIButtonTypeDetailDisclosure

    map_screen.action_called.should == false
    v.rightCalloutAccessoryView.sendActionsForControlEvents(UIControlEventTouchUpInside)
    map_screen.action_called.should == true
  end

  it "should allow a user to set an action with a custom button type" do
    ann = default_annotation.merge({
      action: :my_action_with_sender,
      action_button_type: UIButtonTypeContactAdd
    })
    map_screen.add_annotation ann
    annot = map_screen.annotations.last
    annot.should.be.kind_of?(ProMotion::MapScreenAnnotation)
    v = map_screen.annotation_view(map_screen.mapview, annot)

    v.rightCalloutAccessoryView.class.should == UIButton
    v.rightCalloutAccessoryView.buttonType.should == UIButtonTypeContactAdd
  end

  it 'should allow you to set different properties of MKMapView' do
    map_screen.map.mapType.should == MKMapTypeStandard
    map_screen.map.mapType = MKMapTypeHybrid
    map_screen.map.mapType.should == MKMapTypeHybrid

    map_screen.map.isZoomEnabled.should == true
    map_screen.map.zoomEnabled = false
    map_screen.map.isZoomEnabled.should == false

    map_screen.map.isRotateEnabled.should == true
    map_screen.map.rotateEnabled = false
    map_screen.map.isRotateEnabled.should == false
  end

end
