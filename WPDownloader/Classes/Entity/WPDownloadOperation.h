//
//  WPDownloadOperation.h
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WPDownloaderDefine.h"

@class WPDownloadOperation;


@protocol WPDownloadOperationDelegate <NSObject>

/// operation start操作
-(void)operationStart:(WPDownloadOperation *)operation;
/// operation cancel操作
@optional
-(void)operationCancel:(WPDownloadOperation *)operation;

@end

@interface WPDownloadOperation : NSOperation

@property (nonatomic, copy, readonly) NSString *downloadUrlString;
@property (nonatomic, copy, readonly) NSString *destinationPath;

@property (nonatomic, strong) NSMutableArray<WPDownloadCompletedBlock> *completedBlocks;

@property (nonatomic, strong) NSMutableArray<WPDownloadProgressBlock> *progressBlocks;

@property(nonatomic, weak) id <WPDownloadOperationDelegate>delegate;

- (instancetype)initWithDownloadUrlString:(NSString *)downloadUrlString destinationPath:(NSString *)destinationPath;
- (instancetype)initWithOldOperation:(WPDownloadOperation *)operation;
/// 操作完成时候外部调用改变状态
- (void)completeOperation;

@end
