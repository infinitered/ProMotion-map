# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'
Bundler.require(:development)
require 'ProMotion'
require 'ProMotion-map'
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ProMotion-map'
  app.info_plist['MGLMapboxAccessToken'] = 'pk.eyJ1IjoiZGlvZ29hbmRyZSIsImEiOiJvT0lWd0JJIn0.9K1ORT72EUNOVIiGMIGUPA'
  app.info_plist['MGLMapboxMetricsEnabledSettingShownInApp'] = true
  app.info_plist['NSLocationAlwaysUsageDescription'] = "User tracking"
  app.info_plist['UIBackgroundModes'] = ['location','fetch']
  # app.sdk_version = "8.4"
  # app.deployment_target = '8.4'
end
