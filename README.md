# ProMotion-map

[![Gem Version](https://badge.fury.io/rb/ProMotion-map.svg)](http://badge.fury.io/rb/ProMotion-map) [![Build Status](https://travis-ci.org/clearsightstudio/ProMotion-map.svg)](https://travis-ci.org/clearsightstudio/ProMotion-map) [![Code Climate](https://codeclimate.com/github/clearsightstudio/ProMotion-map.png)](https://codeclimate.com/github/clearsightstudio/ProMotion-map)

ProMotion-map provides a PM::MapScreen, extracted from the
popular RubyMotion gem [ProMotion](https://github.com/clearsightstudio/ProMotion).

## Installation

```ruby
gem 'ProMotion-map'
```

## Usage

Easily create a map screen, complete with annotations.

*Has all the methods of PM::Screen*

```ruby
class MyMapScreen < PM::MapScreen
  title "My Map"
  start_position latitude: 35.090648651123, longitude: -82.965972900391, radius: 4

  def on_appear
    update_annotation_data
  end

  def annotation_data
    [{
      longitude: -82.965972900391,
      latitude: 35.090648651123,
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest"
    },{
      longitude: -82.966093558105,
      latitude: 35.092520895652,
      title: "Turtleback Falls",
      subtitle: "Nantahala National Forest"
    },{
      longitude: -82.95916,
      latitude: 35.07496,
      title: "Windy Falls"
    },{
      longitude: -82.943031505056,
      latitude: 35.102516828489,
      title: "Upper Bearwallow Falls",
      subtitle: "Gorges State Park"
    },{
      longitude: -82.956244328014,
      latitude: 35.085548421623,
      title: "Stairway Falls",
      subtitle: "Gorges State Park",
      your_param: "CustomWhatever"
    }, {
      longitude: -82.965972900391,
      latitude: 35.090648651123,
      title: "Rainbow Falls",
      subtitle: "Nantahala National Forest",
      image: UIImage.imageNamed("custom-pin")
    }]
  end


end
```

Here's a neat way to zoom into a specific marker in an animated fashion and then select the marker:

```ruby
def zoom_to_marker(marker)
  set_region region(coordinate: marker.coordinate, span: [0.05, 0.05])
  select_annotation marker
end
```

---

### Methods

#### annotation_data

Method that is called to get the map's annotation data and build the map. If you do not want any annotations, simply return an empty array.

```ruby
def annotation_data
  [{
    longitude: -82.965972900391,
    latitude: 35.090648651123,
    title: "Rainbow Falls",
    subtitle: "Nantahala National Forest"
  },{
    longitude: -82.965972900391,
    latitude: 35.090648651123,
    title: "Rainbow Falls",
    subtitle: "Nantahala National Forest",
    image: "custom-pin" # Use your own custom image. It will be converted to a UIImage automatically.
  },{
    longitude: -82.966093558105,
    latitude: 35.092520895652,
    title: "Turtleback Falls",
    subtitle: "Nantahala National Forest"
  },{
    longitude: -82.95916,
    latitude: 35.07496,
    title: "Windy Falls"
  },{
    longitude: -82.943031505056,
    latitude: 35.102516828489,
    title: "Upper Bearwallow Falls",
    subtitle: "Gorges State Park"
  },{
    longitude: -82.956244328014,
    latitude: 35.085548421623,
    title: "Stairway Falls",
    subtitle: "Gorges State Park",
    your_param: "CustomWahtever"
  }]
end
```

You may pass whatever properties you want in the annotation hash, but `:longitude`, `:latitude`, and `:title` are required.

Use `:image` to specify a custom image. Pass in a string to conserve memory and it will be converted using `UIImage.imageNamed(your_string)`. If you pass in a `UIImage`, we'll use that, but keep in mind that there will be another unnecessary copy of the UIImage in memory.

Use `:left_accessory` and `:right_accessory` to specify a custom accessory, like a button.

You can access annotation data you've arbitrarily stored in the hash by calling `annotation_instance.annotation_params[:your_param]`.

#### update_annotation_data

Forces a reload of all the annotations

#### center

Returns a `CLLocation2D` instance with the center coordinates of the map.

#### center=({latitude: Float, longitude: Float, animated: Boolean})

Sets the center of the map. `animated` property defaults to `true`.

#### annotations

Returns an array of all the annotations.

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

#### zoom_to_fit_annotations(animated=true)

Changes the zoom and center point of the `MapScreen` to fit all the annotations.

#### set_region(region, animated=true)

Sets the region of the `MapScreen`. `region` should be an instance of `MKCoordinateRegion`.

#### region(params)

Helper method to create an `MKCoordinateRegion`. Expects a hash in the form of:

```ruby
my_region = region({
  coordinate:{
    latitude: 35.0906,
    longitude: -82.965
  },
  # span is the latitude and longitude delta
  span: [0.5, 0.5]
})
```

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

---

### Accessors

#### mapview

Reference to the created UIMapView.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make some specs pass
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
