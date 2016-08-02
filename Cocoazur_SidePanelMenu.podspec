#
# Be sure to run `pod lib lint CocoazurLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Cocoazur_SidePanelMenu'
  s.source_files     = 'CocoazurLib/Classes/SidePanelMenu/**/*'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Cocoazur_SidePanelMenu.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/CocoazurLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tamara Bernad' => 'tamarinda@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/CocoazurLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.dependency 'SwiftyDropbox', '~> 3.0.0'
end
