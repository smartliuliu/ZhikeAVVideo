//
//  ZhikePlayerContainView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayGesBaseView.h"

@protocol ZhikePlayerViewDelegate <NSObject>

@required
/** 点击返回按钮 */
- (void)zhikePlayerBack:(id)sender;


@optional
/** 播放进度 */
- (void)zhikePlayerCurrentTime:(NSTimeInterval)currentTime sender:(id)sender;
/** 播放总时间 */
- (void)zhikePlayerDurationTime:(NSTimeInterval)duration sender:(id)sender;
/** 缓存进度 */
- (void)zhikePlayerBufferTime:(NSTimeInterval)bufferTime sender:(id)sender;
/** 播放结束 */
- (void)zhikePlayerPlayEnded:(id)sender;
/** 播放出现错误 */
- (void)zhikePlayerPlayFailed:(id)sender;
/** 横屏播放（根据自己业务处理， 如存在导航条，那么横屏需要隐藏） */
- (void)zhikePlayerEnterFullScreen:(id)sender;
/** 竖屏播放 */
- (void)zhikePlayerEnterPortrait:(id)sender;

@end


/** 播放器最外层UI */
@interface ZhikePlayerContainView : ZhikePlayGesBaseView


#pragma mark - required
/*** 需要横屏显示清晰度 选项 传递 smoothArray && smoothIndex，否则传递 urlString *****/
/** 清晰度数组
 * 注：eg:[@{@"playUrl":@"123.mp4",  @"name":@"超清"}, @{}....] 如不想横屏出现"清晰度"，则这个数组为空
 */
@property (nonatomic, strong) NSArray *smoothArray;
/** 当前清晰度index */
@property (nonatomic, assign) NSInteger smoothIndex;
/** 播放地址，
 * 注：适合无清晰度，单一视频源播放（如果有smoothArray，则设置urlString无用）
 */
@property (nonatomic,strong) NSString *urlString;
/*************************************************************************/

@property (nonatomic, weak) id<ZhikePlayerViewDelegate> delegate;


#pragma mark - optional
/** 倍速数组
 * 如不想横屏出现"倍速"，则这个数组为空
 */
@property (nonatomic, strong) NSArray *ratesArray;
/** 当前倍速index */
@property (nonatomic, assign) NSInteger rateIndex;
/** 视频标题 */
@property (nonatomic, strong) NSString *videoTitle;
/** 背景图 */
@property (nonatomic,strong) NSString *coverImageUrl;
/** 是否后台播放 */
@property (nonatomic, assign) BOOL playInBackground;
/** 仅显示全屏播放, 只支持全屏模式 default: NO */
@property (nonatomic, assign) BOOL isOnlyFullScreen;
/** 静音播放 default: NO */
@property (nonatomic, assign) BOOL muted;
/** 从某个时间段开始播放 */
@property (nonatomic, assign) CGFloat seekTime;
/** mode */
@property (nonatomic, assign) AVLayerVideoGravity scalingMode;

#pragma mark - 需要注意
/** 是否支持自动转屏
 * default: NO
 * 根据自己业务线处理转屏问题
 * 注：1. 设置了isOnlyFullScreen = YES，在设置shouldAutorotate这个属性无用，仅仅全屏显示是没有自动转屏的
      2. 当前页面 跳转下一级页面， 可通过这个属性关闭自动转屏
      3. 下一级页面 跳转回当前页面， 可通过这个属性打开自动转屏
 */
@property (nonatomic, assign) BOOL shouldAutorotate;



#pragma mark - Method
/** 播放视频(起播 和 继续播放) */
- (void)playVideo;
/** 暂停视频 */
- (void)pausedVideo;
/** 重新播放(从0开始当前视频) */
- (void)replayVideo;
/** 关闭播放器 */
- (void)teardownPlayer;
@end
