//
//  ZhikePlayer.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/9.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, ZKPlayerPlaybackState) {
    ZKPlayerPlayStateUnknown = 0,
    ZKPlayerPlayStatePlaying,
    ZKPlayerPlayStatePaused,
    ZKPlayerPlayStatePlayInterrupted, // 播放中止
    ZKPlayerPlayStatePlayFailed, // 播放出现错误
    ZKPlayerPlayStatePlayEnded, // 播放结束
    ZKPlayerPlayStatePlayUserExited, // 用户退出播放
    ZKPlayerPlayStatePlayStopped, // shutdown  播放停止
};

typedef NS_OPTIONS(NSUInteger, ZKPlayerLoadState) {
    ZKPlayerLoadStateUnknown = 0,
    ZKPlayerLoadStatePrepare,         // 调用开始播放（不一定成功）
    ZKPlayerLoadStatePlayable,       // 加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全
    ZKPlayerLoadStatePlaythroughOK, // 加载完成，即将播放
    ZKPlayerLoadStateStalled , // 可能由于网速不好等因素导致了暂停
};

@protocol ZhikePlayerDelegate <NSObject>

/** 加载播放状态 */
- (void)zhikeVideo:(id)videoPlayer loadState:(ZKPlayerLoadState)state;
/** 播放状态 */
- (void)zhikeVideo:(id)videoPlayer playState:(ZKPlayerPlaybackState)state;
/** 播放进度 */
- (void)zhikeVideo:(id)videoPlayer playCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)duration;
- (void)zhikeVideo:(id)videoPlayer playBufferTime:(NSTimeInterval)bufferTime;

@end

/** 播放内核 */
@interface ZhikePlayer : UIView

@property (nonatomic, weak) id<ZhikePlayerDelegate> playDelegate;
@property (nonatomic,strong) NSString *urlString;
@property (nonatomic, assign) CGFloat progressUpdateInterval;// 进度回调毫秒数
@property (nonatomic, assign) CGFloat volume;// 音量
@property (nonatomic, assign) CGFloat rate; // 倍速
@property (nonatomic, assign) BOOL muted; // 静音
@property (nonatomic, assign) BOOL playInBackground; //后台播放 default: NO

@property (nonatomic, assign) CGFloat currentTime;
@property (nonatomic, assign) CGFloat totalTime;
@property (nonatomic, assign) CGFloat bufferTime;
@property (nonatomic, assign) CGFloat seekTime;

@property (nonatomic, assign) BOOL  isPlaying; // 是否正在播放

@property (nonatomic, assign) ZKPlayerLoadState loadState; // 加载状态
@property (nonatomic, assign) ZKPlayerPlaybackState playState; // 播放状态
@property (nonatomic, assign) AVLayerVideoGravity scalingMode; // mode

/** 后台播发，// 如果找不到关键帧图片，用默认图*/
@property (nonatomic,strong) NSString *coverImageUrl;

/** 开始播放（如果正在播放，则继续播放） */
- (void)play;
/** 暂停 */
- (void)pause;
/** 重新播放(从0开始当前视频) */
- (void)replay;
/** 重新加载播放器 */
- (void)reloadNowPlayer;
/** seek */
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;
- (void)shutdown;

// 生命周期
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;


@end


