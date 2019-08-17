Pod::Spec.new do |s|
  s.name             = 'AR2DFaceDetector'
  s.version          = '0.1.0'
  s.summary          = 'A short description of AR2DFaceDetector.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/noppefoxwolf/AR2DFaceDetector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'noppefoxwolf' => 'noppelabs@gmail.com' }
  s.source           = { :git => 'https://github.com/noppefoxwolf/AR2DFaceDetector.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/noppefoxwolf'
  s.ios.deployment_target = '11.0'
  s.swift_versions = ['5.0']
  s.source_files = 'AR2DFaceDetector/Classes/**/*'
end
