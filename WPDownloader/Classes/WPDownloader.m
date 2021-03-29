//
//  WPDownloader.m
//  DownLoadTest
//
//  Created by pengjizong on 2020/5/22.
//  Copyright © 2020 wespy. All rights reserved.
//

#import "WPDownloader.h"
#import "WPDownloadFailureRecord.h"
#import <CommonCrypto/CommonCrypto.h>
#import <AFNetworking/AFNetworking.h>

//字符串是否为空
#define WPStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )


@interface WPDownloader ()<WPDownloadOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, strong) NSMutableDictionary<NSString *, WPDownloadOperation *> *downloadingRecordCache;
@property (nonatomic, strong) NSCache<NSString *,WPDownloadFailureRecord *> *downloadFailureRecordCache;
@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@end

@implementation WPDownloader

- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.downloadTimeout = 30;
    self.maxConcurrentOperationCount = 5;
    self.maxRetryTime = 3;
    
    self.cachePath = self.defaultDirectory;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
}

- (void)downloadUrl:(NSString *)urlString
              param:(WPDownloadParam *)param
         onProgress:(WPDownloadProgressBlock)onProgress
        onCompleted:(WPDownloadCompletedBlock)onCompleted
{
    if (!param) {
        param = [WPDownloadParam new];
        param.priority = NSOperationQueuePriorityNormal;
    }
    [self downloadUrl:urlString toPath:param.toPath priority:param.priority onProgress:onProgress onCompleted:onCompleted];
}

- (void)downloadUrl:(NSString *)urlString
             toPath:(NSString *)path
           priority:(NSOperationQueuePriority)priority
         onProgress:(WPDownloadProgressBlock)onProgress
        onCompleted:(WPDownloadCompletedBlock)onCompleted
{
    // 正在下载
    if ([self isDownloading:urlString]) {
        WPDownloadOperation *operation = [self.downloadingRecordCache objectForKey:[self getMd5FromString:urlString]];
        if (onCompleted) {
            [operation.completedBlocks addObject:onCompleted];
        }
        if (onProgress) {
            [operation.progressBlocks addObject:onProgress];
        }
        return;
    }
    
    WPDownloadOperation *operation = [[WPDownloadOperation alloc] initWithDownloadUrlString:urlString destinationPath:path];
    operation.delegate = self;
    operation.queuePriority = priority;
    if (onProgress) {
        [operation.progressBlocks addObject:onProgress];
    }
    if (onCompleted) {
        [operation.completedBlocks addObject:onCompleted];
    }
    
    //已经下载完成
    if ([self fileDownloaded:operation.downloadUrlString path:path]) {
        if (operation.completedBlocks.count) {
            NSString *destination = operation.destinationPath.length?operation.destinationPath:[self fileDiskPathWithUrl:operation.downloadUrlString];
            for (WPDownloadCompletedBlock block in operation.completedBlocks) {
                block(destination, nil);
            }
        }
        [operation completeOperation];
        return;
    }
    
    //加入正在下载队列
    [self.downloadingRecordCache setObject:operation forKey:[self getMd5FromString:operation.downloadUrlString]];
    [self.queue addOperation:operation];
}

- (void)cancelUrl:(NSString *)urlString
{
    if ([self isDownloading:urlString]) {
        WPDownloadOperation *operation = [self.downloadingRecordCache objectForKey:[self getMd5FromString:urlString]];
        [operation cancel];
    }
}

#pragma mark - Operation
- (void)operationStart:(WPDownloadOperation *)operation
{
    if (operation.isCancelled) {
        if (operation.completedBlocks.count) {
            for (WPDownloadCompletedBlock block in operation.completedBlocks) {
                block(nil, nil);
            }
        }
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:operation.downloadUrlString]];
    
    __weak __typeof(self)weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSUInteger persent = (unsigned long)(downloadProgress.completedUnitCount*100.0f/downloadProgress.totalUnitCount);
        if (operation.progressBlocks.count) {
            for (WPDownloadProgressBlock block in operation.progressBlocks) {
                block(persent);
            }
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        if (operation.isCancelled) {
            return nil;
        }
        NSURL *destination = [NSURL fileURLWithPath:operation.destinationPath.length ? operation.destinationPath : [weakSelf fileDiskPathWithUrl:operation.downloadUrlString]];
        return destination;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [weakSelf.downloadingRecordCache removeObjectForKey:[self getMd5FromString:operation.downloadUrlString]];
        [operation completeOperation];
        
        if (operation.isCancelled) {
            if (operation.completedBlocks.count) {
                for (WPDownloadCompletedBlock block in operation.completedBlocks) {
                    block(nil, nil);
                }
            }
            return;
        }
        
        if (error) {
            WPDownloadFailureRecord *record = [weakSelf.downloadFailureRecordCache objectForKey:[self getMd5FromString:operation.downloadUrlString]];
            if (!record) {
                record = [WPDownloadFailureRecord new];
            }
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            
            if (record.retryTime < weakSelf.maxRetryTime) {
                record.retryTime++;
                record.downloadOperation = [[WPDownloadOperation alloc] initWithOldOperation:operation];
                //失败重试
                [strongSelf.downloadFailureRecordCache setObject:record forKey:[self getMd5FromString:operation.downloadUrlString]];
                
                [strongSelf.downloadingRecordCache setObject:record.downloadOperation forKey:[self getMd5FromString:operation.downloadUrlString]];
                
                [strongSelf.queue addOperation:record.downloadOperation];
            }else{
                //重试三次 通知下载失败
                if (operation.completedBlocks.count) {
                    for (WPDownloadCompletedBlock block in operation.completedBlocks) {
                        block(nil, error);
                    }
                }
                
                [strongSelf.downloadingRecordCache removeObjectForKey:[self getMd5FromString:operation.downloadUrlString]];
            }
        }else{
            //通知成功
            if (operation.completedBlocks.count) {
                NSString *destination = operation.destinationPath.length?operation.destinationPath:[weakSelf fileDiskPathWithUrl:operation.downloadUrlString];
                for (WPDownloadCompletedBlock block in operation.completedBlocks) {
                    block(destination, nil);
                }
            }
            //下载成功
            WPDownloadFailureRecord *record = [weakSelf.downloadFailureRecordCache objectForKey:[self getMd5FromString:operation.downloadUrlString]];
            if (record) {
                [weakSelf.downloadingRecordCache removeObjectForKey:[self getMd5FromString:operation.downloadUrlString]];
            }
        }
    }];
    [downloadTask resume];
}

- (BOOL)fileDownloaded:(NSString *)url {
    return [self fileDownloaded:url path:nil];
}

- (BOOL)fileDownloaded:(NSString *)url path:(NSString *)path {
    NSString *defaultPath = [self fileDiskPathWithUrl:url];
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:defaultPath];
    if (!exist) {
        if (!WPStringIsEmpty(path)) {
            exist = [[NSFileManager defaultManager] fileExistsAtPath:path];
        }
    }
    return exist;
}

- (BOOL)isDownloading:(NSString *)url
{
    return ([self.downloadingRecordCache objectForKey:[self getMd5FromString:url]] != nil);
}

- (NSString *)pathForURL:(NSString *)url
{
    return [self fileDiskPathWithUrl:url];
}

#pragma mark - SETTER && GETTER
- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

- (NSString *)fileDiskPathWithUrl:(NSString *)url
{
    //拼接缓存目录
    NSString *downloadDir = self.cachePath;
    //打开文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建Download目录
    [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    //拼接文件路径
    NSString *filePath = [downloadDir stringByAppendingPathComponent:[self cachedFileNameForUrl:url]];
    //返回文件位置的URL路径
    return filePath;
}

// copied from SDWebImage
- (NSString *)cachedFileNameForUrl:(NSString *)url {
    NSString *filename = [self getMd5FromString:url];
    if ([url hasSuffix:@".mp4"]) {
        filename = [filename stringByAppendingString:@".mp4"];
    }else if ([url hasSuffix:@".zip"]) {
        filename = [filename stringByAppendingString:@".zip"];
    }
    return filename;
}

- (NSString *)getMd5FromString:(NSString *)originString
{
    const char *cStr = [originString UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

- (NSString *)defaultDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return  [paths[0] stringByAppendingPathComponent:@"downloads"];
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = self.maxConcurrentOperationCount;
    }
    return _queue;
}

- (NSCache *)downloadFailureRecordCache
{
    if (!_downloadFailureRecordCache) {
        _downloadFailureRecordCache = [[NSCache alloc] init];
        _downloadFailureRecordCache.countLimit = 100;
    }
    return _downloadFailureRecordCache;
}

- (NSMutableDictionary *)downloadingRecordCache
{
    if (!_downloadingRecordCache) {
        _downloadingRecordCache = [[NSMutableDictionary alloc] init];
    }
    return _downloadingRecordCache;
}


@end
