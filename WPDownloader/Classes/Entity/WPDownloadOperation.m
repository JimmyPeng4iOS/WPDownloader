//
//  WPDownloadOperation.m
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#import "WPDownloadOperation.h"

@interface WPDownloadOperation ()

/// 是否正在进行
@property (nonatomic, assign) BOOL bees_executing;

/// 是否完成
@property (nonatomic, assign) BOOL bees_finished;


@end

@implementation WPDownloadOperation

-(instancetype)initWithDownloadUrlString:(NSString *)downloadUrlString destinationPath:(NSString *)destinationPath{
    if (self = [super init]) {
        _bees_executing = NO;
        _bees_finished = NO;
        _downloadUrlString = downloadUrlString;
        _destinationPath = destinationPath;
    }
    return self;
}


- (instancetype)initWithOldOperation:(WPDownloadOperation *)operation
{
    if (self = [super init]) {
        _bees_executing = NO;
        _bees_finished = NO;
        _downloadUrlString = operation.downloadUrlString;
        _destinationPath = operation.destinationPath;
        _delegate = operation.delegate;
        _completedBlocks = operation.completedBlocks;
        _progressBlocks = operation.progressBlocks;
    }
    return self;
}

- (void)start {
    if (self.isCancelled) {
        // 若当前操作为取消，则结束操作，且要修改isExecuting和isFinished的值
        NSLog(@"%@ cancel %@", self.downloadUrlString,self);
        if ([self.delegate respondsToSelector:@selector(operationCancel:)]) {
            [self.delegate operationCancel:self];
        }
        [self completeOperation];
    } else {
        // 正在执行操作
        self.bees_executing = YES;
        // 通过代理，在外部实现对应的异步操作
        if (self.delegate && [self.delegate respondsToSelector:@selector(operationStart:)]) {
            [self.delegate operationStart:self];
        }
    }
}

/// 结束当前操作，改变对应的状态
- (void)completeOperation {
    self.bees_executing = NO;
    self.bees_finished = YES;
}

// 重写cancel方法，结束状态
- (void)cancel {
    [super cancel];
    // 取消后调用完成，删除queue中的operation
    [self completeOperation];
}

#pragma mark - SETTER && GETTER
// setter 修改自己状态的同时，发送父类对应属性状态改变的kvo通知
- (void)setBees_executing:(BOOL)bees_executing {
    [self willChangeValueForKey:@"isExecuting"];
    _bees_executing = bees_executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)setBees_finished:(BOOL)bees_finished {
    [self willChangeValueForKey:@"isFinished"];
    _bees_finished = bees_finished;
    [self didChangeValueForKey:@"isFinished"];
}

// 父类返回自己维护的对应的状态
- (BOOL)isExecuting {
    return self.bees_executing;
}

- (BOOL)isFinished {
    return self.bees_finished;
}

- (NSMutableArray<WPDownloadCompletedBlock> *)completedBlocks
{
    if (!_completedBlocks) {
        _completedBlocks = [NSMutableArray array];
    }
    return _completedBlocks;
}

- (NSMutableArray<WPDownloadProgressBlock> *)progressBlocks
{
    if (!_progressBlocks) {
        _progressBlocks = [NSMutableArray array];
    }
    return _progressBlocks;
}

@end
