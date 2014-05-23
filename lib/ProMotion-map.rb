# encoding: utf-8

unless defined?(Motion::Project::Config)
  raise "ProMotion-map must be required within a RubyMotion project."
end

Motion::Project::App.setup do |app|
  lib_dir_path = File.dirname(File.expand_path(__FILE__))
  app.files << File.join(lib_dir_path, "ProMotion/map/map_screen_annotation.rb")
  app.files << File.join(lib_dir_path, "ProMotion/map/map_screen_module.rb")
  app.files << File.join(lib_dir_path, "ProMotion/map/map_screen.rb")

  app.frameworks += %w(CoreLocation MapKit)
end
