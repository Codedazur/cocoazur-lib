#
# Be sure to run `pod lib lint CocoazurLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Cocoazur_ServicesAlamofire'
  s.source_files     = 'CocoazurLib/Classes/ServicesAlamofire/**/*'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Cocoazur_ServicesAlamofire.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Codedazur/cocoazur-lib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tamara Bernad' => 'tamarinda@gmail.com' }
  s.source           = { :git => 'https://github.com/Codedazur/cocoazur-lib.git', :tag => 'Cocoazur_ServicesAlamofire-'+s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.dependency 'Cocoazur_Services', '~> 0.1.0'
end
