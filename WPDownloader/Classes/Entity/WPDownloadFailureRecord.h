//
//  WPDownloadFailureRecord.h
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPDownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface WPDownloadFailureRecord : NSObject

@property (nonatomic, strong) WPDownloadOperation *downloadOperation;

@property (nonatomic, assign) NSInteger retryTime;

@end

NS_ASSUME_NONNULL_END
