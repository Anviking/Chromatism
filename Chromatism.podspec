Pod::Spec.new do |s|
  s.name        = "Chromatism"
  s.version     = "0.4"
  s.summary     = "iOS Syntax Highlighting in Swift"
  s.homepage    = "https://github.com/Anviking/Chromatism"
  s.license     = { :type => "MIT" }
  s.authors     = { "anviking" => "anviking@me.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "10.0"
  s.source   = { :git => "https://github.com/Anviking/Chromatism", :tag => "0.4"}
  s.source_files = "Chromatism/*.swift"
end
