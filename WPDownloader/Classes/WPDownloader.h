//
//  WPDownloader.h
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPDownloaderDefine.h"
#import "WPDownloadParam.h"

@interface WPDownloader : NSObject

@property (nonatomic, assign) NSInteger maxConcurrentOperationCount; // defalut is 5;
@property (nonatomic, assign) NSInteger downloadTimeout; // defalut is 30;
@property (nonatomic, assign) NSInteger maxRetryTime; // defalut is 3;

@property (nonatomic, copy) NSString *cachePath; //default is  NSDocumentDirectory/downloads

- (void)downloadUrl:(NSString *)urlString
              param:(WPDownloadParam *)param
         onProgress:(WPDownloadProgressBlock)onProgress
        onCompleted:(WPDownloadCompletedBlock)onCompleted;

- (void)cancelUrl:(NSString *)urlString;

- (BOOL)fileDownloaded:(NSString *)url;

- (BOOL)isDownloading:(NSString *)url;

- (NSString *)pathForURL:(NSString *)url;

@end

