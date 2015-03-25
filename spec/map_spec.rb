describe "map properties" do

  before do
    # Simulate AppDelegate setup of map screen
    @map = TestMapScreen.new modal: true, nav_bar: true
    @map.view_will_appear(false)
  end

  it "should store title" do
    @map.title.should == "Gorges State Park, NC"
  end

  it "should have 5 annotations" do
    @map.annotations.count.should == 5
  end

  it "should convert annotation hashes to MapViewAnnotations" do
    @map.annotations.each do |annotation|
      annotation.class.to_s.should == "NSKVONotifying_MapScreenAnnotation"
    end
  end

  it "should have a default red colored pin" do
    @map.annotations.each do |annotation|
      annotation_view = @map.annotation_view(@map.mapview, annotation)
      annotation_view.pinColor.should == MKPinAnnotationColorRed
    end
  end

  it "should add an annotation" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Something Else"
    }
    @map.add_annotation(ann)
    @map.annotations.count.should == 6
  end

  it "should add an annotation with a different pin color symbol" do
    ann = ProMotion::MapScreenAnnotation.new({
      longitude: -82.966993558105,
      latitude: 35.092520495652,
      title: "Green Pin",
      pin_color: :green
    })
    annotation_view = @map.annotation_view(@map.mapview, ann)
    annotation_view.pinColor.should == MKPinAnnotationColorGreen
  end

  it "should add an annotation with a different pin color constant" do
    ann = ProMotion::MapScreenAnnotation.new({
      longitude: -82.966993558105,
      latitude: 35.092520495652,
      title: "Purple Pin",
      pin_color: MKPinAnnotationColorPurple
    })
    annotation_view = @map.annotation_view(@map.mapview, ann)
    annotation_view.pinColor.should == MKPinAnnotationColorPurple
  end

  it "should add an annotation with a coordinate" do
    ann = {
      coordinate: CLLocationCoordinate2DMake(35.092520895652, -82.966093558105),
      title: "A Coordinate"
    }
    @map.add_annotation(ann)
    @map.annotations.count.should == 6
  end

  it "should return custom annotation parameters" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Custom",
      another_value: "Mark"
    }
    @map.add_annotation(ann)
    @map.annotations.last.another_value.should == "Mark"
  end

  it "should return nil for custom annotation parameters that don't exist" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Custom",
      another_value: "Mark"
    }
    @map.add_annotation(ann)
    old_lev = PM.logger.level
    PM.logger.level = :none
    @map.annotations.last.another_value_fake.should == nil
    PM.logger.level = old_lev
  end

  it "should clear annotations" do
    @map.clear_annotations
    @map.annotations.count.should == 0
  end

  it "should return false when user location is not being shown" do
    @map.showing_user_location?.should == false
  end

  it "should return nil for user location when not being shown" do
    @map.user_location.should == nil
  end

  it "should allow access to teh map via convenience methods" do
    @map.view.should == @map.mapview
    @map.mapview.should == @map.map
  end

  it "should allow ruby counterparts to MKMapView to be used" do
    @map.type.should == MKMapTypeStandard
    @map.type = MKMapTypeHybrid
    @map.map.mapType.should == MKMapTypeHybrid

    @map.zoom_enabled?.should == true
    @map.zoom_enabled = false
    @map.zoom_enabled?.should == false

    @map.scroll_enabled?.should == true
    @map.scroll_enabled = false
    @map.scroll_enabled?.should == false

    @map.pitch_enabled?.should == true
    @map.pitch_enabled = false
    @map.pitch_enabled?.should == false

    @map.rotate_enabled?.should == true
    @map.rotate_enabled = false
    @map.rotate_enabled?.should == false
  end

end
