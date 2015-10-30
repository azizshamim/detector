require File.expand_path('../lib/impdetector.rb', __FILE__)

$stdout.sync = true

run Rack::URLMap.new \
  "/impersonation"       => ImpDetector
