source 'https://cdn.cocoapods.org/'
source 'git@github.com:mercadolibre/mobile-ios_specs.git'

workspace 'CardForm'
project 'Example/Example_CardForm.xcodeproj'

platform :ios, '13.0'
use_frameworks!
# ignore all warnings from all pods
inhibit_all_warnings!

target 'Example_CardForm' do
  pod 'MLCardForm', :path => './', :testspecs => ['Tests']
end
