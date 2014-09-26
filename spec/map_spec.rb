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

  it "should add an annotation" do
    ann = {
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Something Else"
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
    @map.annotations.last.another_value_fake.should == nil
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
    @map.type.should == MKMapTypeHybrid

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
