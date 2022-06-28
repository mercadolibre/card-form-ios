Pod::Spec.new do |s|
  s.name             = "MLCardForm"
  s.version          = "0.11.0"
  s.summary          = "MLCardForm for iOS"
  s.homepage         = "https://www.mercadolibre.com"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "PX Team - Juan Sanzone - Eric Ertl - Esteban Boffa"
  s.source           = { :git => "https://github.com/mercadolibre/card-form-ios", :tag => s.version.to_s }
  s.swift_version    = '5.6'
  s.ios.deployment_target = '10.0'
  s.platform         = :ios, '10.0'
  s.requires_arc     = true
  s.default_subspec = 'Default'
  s.static_framework = true

  s.subspec 'Default' do |default|
    default.source_files = ['Source/**/**/**/*.{h,m,swift}']
    default.resources = ['Source/UI/**/*.xib']
    default.resource_bundles = { 'MLCardFormResources' => ['Source/Resources/*.xcassets', 'Source/Translations/**/**.{strings}'] }
    s.dependency 'MLUI', '~> 5.0'
    s.dependency 'AndesUI', '~> 3.0'
    s.dependency 'MLCardDrawer', '~> 1.0'
  end

  s.test_spec 'Tests' do |test_spec|
      test_spec.requires_app_host = false
      test_spec.source_files = 'Tests/**/*.{swift}'
      test_spec.frameworks = 'XCTest'
  end
end
