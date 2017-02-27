# ProMotion-mapbox

[![Gem Version](https://badge.fury.io/rb/ProMotion-mapbox.svg)](http://badge.fury.io/rb/ProMotion-mapbox)

ProMotion-mapbox provides a PM::MapScreen that users [Mapbox](https://www.mapbox.com) as the map provider. Forked from the
popular RubyMotion gem [ProMotion-map](https://github.com/clearsightstudio/ProMotion-map).

ProMotion-map was created by [Infinite Red](http://infinite.red), a web and mobile development company based in Portland, OR and San Francisco, CA. While you're welcome to use it, please note that we rely on the community to maintain it. We are happy to merge pull requests and release new versions but are no longer driving primary development.

## Installation

```ruby
gem 'ProMotion-mapbox'
```
```ruby
rake pod:install
```


## Usage

Easily create a map screen, complete with annotations.

*Has all the methods of PM::Screen*

```ruby
class MyMapScreen < PM::MapScreen
  title "My Map"
  start_position latitude: 35.090648651123, longitude: -82.965972900391, radius: 4
  tap_to_add

  def annotation_data
    [{
      longitude: -82.965972900391,
      latitude: 35.090648651123,
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest",
      left_action: :show_forest,
      pin_color: :green
    },{
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Turtleback Falls",
      subtitle: "Nantahala National Forest",
      left_action: :show_forest,
      left_action_button_type: UIButtonTypeContactAdd,
      pin_color: :red
    },{
      longitude: -82.95916,
      latitude: 35.07496,
      title: "Windy Falls",
      left_action: :show_forest
    },{
      longitude: -82.943031505056,
      latitude: 35.102516828489,
      title: "Upper Bearwallow Falls",
      subtitle: "Gorges State Park",
      left_action: :show_forest
    },{
      longitude: -82.956244328014,
      latitude: 35.085548421623,
      title: "Stairway Falls",
      subtitle: "Gorges State Park",
      your_param: "CustomWhatever",
      right_action: :show_forest
    },{
      coordinate: CLLocationCoordinate2DMake(35.090648651123, -82.965972900391),
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest",
      image: UIImage.imageNamed("custom-pin"),
      left_action: :show_forest
    }]
  end

  def show_forest
    selected = selected_annotations.first
    # Do something with the selected annotation.
  end
end
```

Here's a neat way to zoom into a specific marker in an animated fashion and then select the marker:

```ruby
def zoom_to_marker(marker)
    set_region region(coordinate: marker.coordinate, radius: 5) # Radius are specified in nautical miles.
  select_annotation marker
end
```

---

### Methods

#### annotation_data

Method that is called to get the map's annotation data and build the map. If you do not want any annotations, simply return an empty array.

All possible properties:

```ruby
{
    # REQUIRED -or- use :coordinate
    longitude: -82.956244328014,
    latitude: 35.085548421623,

    # REQUIRED -or- use :longitude & :latitude
    coordinate: CLLocationCoordinate2DMake(35.085548421623, -82.956244328014)

    title: "Stairway Falls", # REQUIRED
    subtitle: "Gorges State Park",
    image: "my_custom_image",
    pin_color: :red, # Defaults to :red. Other options are :green or :purple. Here as a placeholder only. Modifying a marker color is not yet supported by the Mapbox GL SDK.
    left_accessory: my_button,
    right_accessory: my_other_button,
    action: :my_action, # Overrides :right_accessory
    action_button_type: UIButtonTypeContactAdd # Defaults to UIButtonTypeDetailDisclosure
}
```

You may pass whatever properties you want in the annotation hash, but (`:longitude` && `:latitude` || `:coordinate`), and `:title` are required.

Use `:image` to specify a custom image. Pass in a string to conserve memory and it will be converted using `UIImage.imageNamed(your_string)`. If you pass in a `UIImage`, we'll use that, but keep in mind that there will be another unnecessary copy of the UIImage in memory.

Use `:left_accessory` and `:right_accessory` to specify a custom accessory, like a button.

Use `:left_action` and `:right_action` to specify an action for the left or right accessory view. These properties will create a button for you, and should not be used in conjunction with `:left_accessory` or `:right_accessory`. The type of the button can be specified with the optional parameter `:right_action_button_type`, and defaults to UIButtonTypeDetailDisclosure if not specified.

You can access annotation data you've arbitrarily stored in the hash by calling `annotation_instance.params[:your_param]`.

The `:action` parameter specifies a method that should be run when the detail button is tapped on the annotation. It automatically adds a `UIButtonTypeDetailDisclosure` button to the `:left_accessory`. In your method you can find out which annotation's accessory was tapped by calling `selected_annotations.first`.

#### update_annotation_data

Forces a reload of all the annotations

#### annotations

Returns an array of all the annotations.

#### center

Returns a `CLLocation2D` instance with the center coordinates of the map.

#### center=({latitude: Float, longitude: Float, animated: Boolean})

Sets the center of the map. `animated` property defaults to `true`.

#### show_user_location

Shows the user's location on the map. Must be called in the view initialization sequence on `will_appear` or _after_.

#### track_user_location({ heading: true })

Causes the map view to center the map on that location and begin tracking the user’s location. `heading` defaults to false but will provide a compass heading if set to true.

#### look_up_location(CLLocation) { |placemark, error| }

This method takes a CLLocation object and will return one to many CLPlacemark to represent nearby data.

##### iOS 8 Location Requirements

iOS 8 introduced stricter location services requirements. You are now required to add a few key/value pairs to the `Info.plist`. Add these two lines to your `Rakefile` (with your descriptions, obviously):

```ruby
app.info_plist['NSLocationAlwaysUsageDescription'] = 'Description'
app.info_plist['NSLocationWhenInUseUsageDescription'] = 'Description'
```

*Note: you need both keys to use `get_once`, so it's probably best to just include both no matter what.* See [Apple's documentation](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW18) on iOS 8 location services requirements for more information.

#### hide_user_location

Hides the user's location on the map.

#### showing_user_location?

Returns a `Boolean` of whether or not the map view is currently showing the user's location.

#### user_location

Returns a `CLLocation2D` object of the user's location or `nil` if the user location is not being tracked

#### zoom_to_user(radius = 0.05, animated=true)

Zooms to the user's location. If the user's location is not currently being shown on the map, it will show it first. `radius` is the distance in nautical miles from the center point (user location) to the corners of a virtual bounding box.

#### select_annotation(annotation, animated=true)

Selects a single annotation.

#### select_annotation_at(annotation_index, animated=true)

Selects a single annotation using the annotation at the index of your `annotation_data` array.

#### selected_annotations

Returns an array of annotations that are selected. If no annotations are selected, returns `nil`.

#### deselect_annotations(animated=false)

Deselects all selected annotations.

#### add_annotation(annotation)

Adds a new annotation to the map. Refer to `annotation_data` (above) for hash properties.

#### add_annotations(annotations)

Adds more than one annotation at a time to the map.

#### clear_annotations

Removes all annotations from the `MapScreen`.

#### zoom_to_fit_annotations({animated:true, include_user:false})

Changes the zoom and center point of the `MapScreen` to fit all the annotations. Passing `include_user` as `true` will cause the zoom to not only include the annotations from `annotation_data` but also the user pin in the zoom region calculation.

#### set_region(region, animated=true)

Sets the region of the `MapScreen`. `region` should be an instance of `MKCoordinateRegion`.

#### region(center_location,radius=10)

Mapbox doesn't use the concept of regions. Instead, we can zoom to a virtual bounding box defined by its Sourthwest and Northeast
corners.
The ```region``` methods takes a ```center_location``` and a radius. The distance from the center to the corners (and thus the zoom level) will be the ```radius``` times 1820 meters (1 Nautical mile)

```ruby
my_region = region({
  CLLocationCoordinate2D.new(35.0906,-82.965),
  radius: 11
})

---

### Class Methods

#### start_position(latitude: Float, longitude: Float, radius: Float)

Class method to set the initial starting position of the `MapScreen`.

```ruby
class MyMapScreen < PM::MapScreen
  start_position latitude: 36.10, longitude: -80.26, radius: 4
end
```

`radius` is the zoom level of the map in miles (default: 10).

#### tap_to_add(length: Float, target: Object, action: Selector, annotation: Hash)

Lets a user long press the map to drop an annotation where they pressed.

##### Default values:

You can override any of these values. The `annotation` parameter can take any options specified in the annotation documentation above except `:latitude`, `:longitude`, and `:coordinate`.

```ruby
length: 2.0,
target: self,
action: "gesture_drop_pin:",
annotation: {
  title: "Dropped Pin",
  animates_drop: true
}
```

##### Notifications

This feature posts two different `NSNotificationCenter` notifications:

**ProMotionMapWillAddPin:** Fired the moment the long press gesture is recognized, before the pin is added.

**ProMotionMapAddedPin:** Fired after the pin has been added to the map.

##### Example:

```ruby
# Simple Example
class MyMapScreen < PM::MapScreen
  title "My Map Screen"
  tap_to_add length: 1.5
  def annotations
    []
  end
end
```

```ruby
# A More Complex Example
class MyMapScreen < PM::MapScreen
  title "My Map Screen"
  tap_to_add length: 1.5, annotation: {animates_drop: true, title: "A Cool New Pin"}
  def annotations
    []
  end

  def will_appear
    NSNotificationCenter.defaultCenter.addObserver(self, selector:"pin_adding:", name:"ProMotionMapWillAddPin", object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector:"pin_added:", name:"ProMotionMapAddedPin", object:nil)
  end

  def will_disappear
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def pin_adding(notification)
    # We only want one pin on the map at a time
    clear_annotations
  end

  def pin_added(notification)
    # Once the pin is dropped we want to select it
    select_annotation_at(0)
  end
end
```

---

### Delegate callbacks

These methods (if implemented in your `MapScreen`) will be called when the corresponding `MKMapViewDelegate` method is invoked:

```ruby
def will_change_region(animated)
  # Do something when the region will change
  # The animated parameter is optional so you can also define it is simply:
  # def will_change_region
  # end
end

def on_change_region(animated)
  # Do something when the region changed
  # The animated parameter is optional so you can also define it is simply:
  # def on_change_region
  # end
end
```

---

### CocoaTouch Property Convenience Methods

`MKMapView` contains multiple property setters and getters that can be accessed in a more ruby-like syntax:

```ruby
type # Returns a MKMapType
type = (MKMapType)new_type

zoom_enabled?
zoom_enabled = (bool)enabled

scroll_enabled?
scroll_enabled = (bool)enabled

pitch_enabled?
pitch_enabled = (bool)enabled

rotate_enabled?
rotate_enabled = (bool)enabled
```

---

### Accessors

#### `map` or `mapview`

Reference to the created MLGMapView.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make some specs pass
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
