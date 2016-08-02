# CocoazurLib

[![CI Status](http://img.shields.io/travis/Tamara Bernad/CocoazurLib.svg?style=flat)](https://travis-ci.org/Tamara Bernad/CocoazurLib)
[![Version](https://img.shields.io/cocoapods/v/CocoazurLib.svg?style=flat)](http://cocoapods.org/pods/CocoazurLib)
[![License](https://img.shields.io/cocoapods/l/CocoazurLib.svg?style=flat)](http://cocoapods.org/pods/CocoazurLib)
[![Platform](https://img.shields.io/cocoapods/p/CocoazurLib.svg?style=flat)](http://cocoapods.org/pods/CocoazurLib)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

CocoazurLib is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
git add -A && git commit -m "Cocoazur_Core-0.0.19"
git add -A && git commit -m "Cocoazur_Dropbox-0.0.19"
git add -A && git commit -m "Cocoazur_ServicesAlamofire-0.0.19"
git add -A && git commit -m "Cocoazur_Services-0.1.0"

git tag 'Cocoazur_Core-0.0.19'
git tag 'Cocoazur_Dropbox-0.0.19'
git tag 'Cocoazur_ServicesAlamofire-0.0.19'
git tag 'Cocoazur_Services-0.1.0'

git push --tags
pod repo push bitbucket-cda-ios-pods Cocoazur_Core.podspec --allow-warnings --use-libraries
pod repo push bitbucket-cda-ios-pods Cocoazur_Dropbox.podspec --allow-warnings --use-libraries
pod repo push bitbucket-cda-ios-pods Cocoazur_ServicesAlamofire.podspec --allow-warnings --use-libraries
pod repo push bitbucket-cda-ios-pods Cocoazur_Services.podspec --allow-warnings --use-libraries

```

## Author

Tamara Bernad, tamarinda@gmail.com

## License

CocoazurLib is available under the MIT license. See the LICENSE file for more info.
