#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "WPDownloadFailureRecord.h"
#import "WPDownloadOperation.h"
#import "WPDownloadParam.h"
#import "WPDownloader.h"
#import "WPDownloaderDefine.h"

FOUNDATION_EXPORT double WPDownloaderVersionNumber;
FOUNDATION_EXPORT const unsigned char WPDownloaderVersionString[];

