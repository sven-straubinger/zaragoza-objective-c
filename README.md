# zaragoza-objective-c
An application for an application – written in Objective-C, backed with [CocoaPods](https://cocoapods.org).

In a first step, all available bus stops are loaded in a table view, followed by lazy requests for estimated time of arrival (ETA) and images for visible rows only.

## Prerequisites

You need to install [CocoaPods](https://cocoapods.org) to get started.

## Getting started

1. Checkout project
2. Run `pod install`
3. Use workspace by opening `zaragoza.xcworkspace`

## Next steps

* add way more tests
* extend tests: mock HTTP requests by an own, [canned implementation of NSURLProtocol](http://www.infinite-loop.dk/blog/2011/09/using-nsurlprotocol-for-injecting-test-data/)
* sort bus stops by distance to user location
* refactor ImageDownloader to use AFNetworking
* review AFNetworking leaks (Instruments)
