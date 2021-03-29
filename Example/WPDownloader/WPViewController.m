//
//  WPViewController.m
//  WPDownloader
//
//  Created by pengjizong on 03/29/2021.
//  Copyright (c) 2021 pengjizong. All rights reserved.
//

#import "WPViewController.h"
#import <WPDownloader.h>

@interface WPViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic, strong) WPDownloader *downloader;

@end

@implementation WPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.downloader = [[WPDownloader alloc] init];

    WPDownloadParam *param = [WPDownloadParam new];
    param.priority = NSOperationQueuePriorityHigh;
//    param.toPath = ;

    NSString *urlString = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3842734942,2708642318&fm=26&gp=0.jpg";
    
    __weak __typeof(self)weakSelf = self;
    [self.downloader downloadUrl:urlString param:param onProgress:^(NSUInteger percent) {
        NSLog(@"percent = %ld",percent);
    } onCompleted:^(NSString *filePath, NSError *error) {
        NSLog(@"filePath = %@",filePath);
        weakSelf.imgView.image = [UIImage imageWithContentsOfFile:filePath];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
