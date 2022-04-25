Pod::Spec.new do |s|
  s.name             = "AMWalker"
  s.summary          = "A travel companion for your animations."
  s.version          = "0.10.0"
  s.homepage         = "https://github.com/artemmihelson/Walker"
  s.license          = 'MIT'
  s.author           = { "Artem Mykhelson" => "artem.mykhelson@gmail.com" }
  s.source           = { :git => "https://github.com/artemmihelson/Walker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/artem_mihelson'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.frameworks = 'AVFoundation'
  s.swift_versions = '5.0'
end
