Pod::Spec.new do |s|
  s.name        = "Chromatism"
  s.version     = "1.0"
  s.summary     = "iOS Syntax Highlighting in Swift"
  s.homepage    = "https://github.com/Anviking/Chromatism"
  s.license     = { :type => "MIT" }
  s.authors     = { "anviking" => "anviking@me.com" }

  s.requires_arc = true
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.source   = { :git => "https://github.com/Anviking/Chromatism", :tag => "1.0"}
  s.source_files = "Chromatism/Chromatism/*.swift"
end
