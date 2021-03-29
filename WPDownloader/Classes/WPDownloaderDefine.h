//
//  WPDownloaderDefine.h
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#ifndef WPDownloaderDefine_h
#define WPDownloaderDefine_h



typedef void (^WPDownloadProgressBlock)(NSUInteger percent);
typedef void (^WPDownloadCompletedBlock)(NSString *filePath, NSError *error);

typedef void(^WPDownloadPrefetcherProgressBlock)(NSUInteger noOfFinishedUrls, NSUInteger noOfTotalUrls);
typedef void(^WPDownloadPrefetcherCompletionBlock)(NSUInteger noOfFinishedUrls, NSUInteger noOfSkippedUrls);


#endif /* WPDownloaderDefine_h */
