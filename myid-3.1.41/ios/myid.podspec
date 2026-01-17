#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint myid.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'myid'
  s.version          = '3.1.3'
  s.summary          = 'MyID flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://pub.dev/packages/myid'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'MyID' => 'https://myid.uz/' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'MyIdSDK', '3.1.3'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
