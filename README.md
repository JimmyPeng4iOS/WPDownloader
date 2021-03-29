# WPDownloader

[![CI Status](https://img.shields.io/travis/pengjizong/WPDownloader.svg?style=flat)](https://travis-ci.org/pengjizong/WPDownloader)
[![Version](https://img.shields.io/cocoapods/v/WPDownloader.svg?style=flat)](https://cocoapods.org/pods/WPDownloader)
[![License](https://img.shields.io/cocoapods/l/WPDownloader.svg?style=flat)](https://cocoapods.org/pods/WPDownloader)
[![Platform](https://img.shields.io/cocoapods/p/WPDownloader.svg?style=flat)](https://cocoapods.org/pods/WPDownloader)

WPDownloader是一个预加载资源的下载工具
1. 支持下载优先级(用于插队下载)
2. 支持多线程下载
3. 支持设置超时时间和最大重试次数
4. 支持自定义缓存路径

WPDownloader is a download tool for pre-loading resources
1. Support download priority (used to jump in line to download)
2. Support multi-threaded download
3. Support setting timeout period and maximum number of retries
4. Support custom cache path

## Usage

```
self.downloader = [WPDownloader new];

WPDownloadParam *param = [WPDownloadParam new];
param.priority = NSOperationQueuePriorityHigh;
param.toPath = xxx;

[self.downloader downloadUrl:url param:param onProgress:^(NSUInteger percent) { 
} onCompleted:^(NSString *filePath, NSError *error) {
}];

```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8+

## Installation

CPYDownloader is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WPDownloader'
```

## Author

JimmyPeng, pengjizong@qq.com

## License

WPDownloader is available under the MIT license. See the LICENSE file for more info.


