//
//  ViewController.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/9.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ViewController.h"
#import <ZhikeVideo/ZhikePlayerContainView.h>
#import <Masonry/Masonry.h>

@interface ViewController ()<ZhikePlayerViewDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    ZhikePlayerContainView *containView = [[ZhikePlayerContainView alloc] init];
    // 播放两种形式
    /**** 方法一：需要横屏清晰度显示， 需要传递smoothArray数组和 播放选中的smoothIndex *******/
    containView.smoothArray = @[@{@"playUrl":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", @"name":@"超清"},
                                @{@"playUrl":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", @"name":@"标清"},];
    containView.smoothIndex = 0;
   /******* 需要横屏清晰度显示  *******/
    
    
    /*** 方法二 不需要 清晰度显示， 则 smoothArray 数组不需传值，赋值urlString播放 *******/
//    containView.urlString = @"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4";
    /*******    如果不想横屏出现"清晰度""倍速"， 则不用传递数组   *******/
    
    
    containView.coverImageUrl = @"http://www.pptbz.com/pptpic/UploadFiles_6909/201211/2012111719294197.jpg";
    containView.videoTitle = @"中国好视频";
    containView.shouldAutorotate = self.shouldAutorotate;
    containView.ratesArray = @[@"0.75", @"1.0", @"1.25", @"1.5", @"2.0"];
    containView.rateIndex = 1;
    containView.isOnlyFullScreen = self.isFull;
    containView.delegate = self;
//    containView.seekTime = 30; // 从某个时间段开始播放
    [self.view addSubview:containView];
    
    //frame 根据自己工程设置frame方式
    // 方法一：直接赋值frame
//    containView.frame = CGRectMake(0, 130, kScalePhone6Value(375), 200);
    // 方法二：masonry
    [containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake([UIScreen mainScreen].bounds.size.width, 200));
        make.top.mas_equalTo(130);
    }];
}



#pragma mark - ZhikePlayerViewDelegate
- (void)zhikePlayerBack:(id)sender {
     [self.navigationController popViewControllerAnimated:YES];
}

/** 横屏播放 */
- (void)zhikePlayerEnterFullScreen:(id)sender {
     NSLog(@"~~~~横~~~~屏~~~~");
    /**
     * 1. 如存在导航条，那么横屏 需要隐藏
     * 2. 如不存在导航条， 这句可忽略，根据自己业务处理导航条
     */
    self.navigationController.navigationBar.hidden = YES;
}

/** 竖屏播放 */
- (void)zhikePlayerEnterPortrait:(id)sender {
    NSLog(@"---竖---屏---");
    /**
     * 1. 如果存在导航条，那么竖屏，需要展示
     * 2. 如不存在导航条， 这句可忽略，根据自己业务处理导航条
     */
    self.navigationController.navigationBar.hidden = NO;
}

- (void)zhikePlayerPlayEnded:(id)sender {
    ZhikePlayerContainView *playView  = sender;
    /*** 不做处理，点击页面按钮，重新播放 ***/
    
    /*** 做处理 两种********************/
    // 1. 自动重播
    [playView replayVideo];
    
    // 2. 播放结束， 播放新视频（seektime：新视频的起播时间）
    /**
    containView.smoothArray = @[@{@"playUrl":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", @"name":@"超清"},
                                @{@"playUrl":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4", @"name":@"标清"},];
    containView.smoothIndex = 0;
//    playView.seekTime = 10; // 这个视频的起播时间，如果有则赋值
    [playView playVideo];
     
    */

}


@end
