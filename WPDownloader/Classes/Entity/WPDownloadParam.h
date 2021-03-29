//
//  WPDownloadParam.h
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/28.
//  Copyright © 2020 wespy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPDownloaderDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface WPDownloadParam : NSObject

//optional
@property (nonatomic, copy) NSString *toPath;  //default is  NSCachesDirectory/downloads
@property (nonatomic, assign) NSOperationQueuePriority priority; //default is  NSOperationQueuePriorityNormal

@end

NS_ASSUME_NONNULL_END
