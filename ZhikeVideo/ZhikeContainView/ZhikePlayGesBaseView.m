
//
//  ZhikePlayGesBaseView.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/14.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayGesBaseView.h"
#import <Masonry/Masonry.h>

@interface ZhikePlayGesBaseView ()<UIGestureRecognizerDelegate> {
    CGPoint _panBeginPoint; // 开始移动的坐标
    
    CGFloat _panBeginTimeValue;
    CGFloat _panBeignVolumeValue;
    CGFloat _panBeginBrightnessValue;
    
    CGFloat _panEndTimeValue;
    CGFloat _panEndVolumeValue;
    CGFloat _panEndBrightnessValue;
}

@end

@implementation ZhikePlayGesBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.player];
        self.backgroundColor = [UIColor redColor];
        [self.player mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self addNotification];
        [self addGes];
    }
    return self;
}



#pragma mark - Get
- (ZhikePlayer *)player {
    if (!_player) {
        _player = [[ZhikePlayer alloc] init];
        _player.playDelegate = self;
    }
    
    return _player;
}



#pragma mark -Public Method
/**fix:
 如果不需要系统的HUD的话, 我们可以把 MPVolumeView 的frame 设置为0, 或者不设置frame, 或者设置到屏幕外面, 都可以.
 如果需要系统的HUD的话, 直接不添加到控制器的view上面就可以, 因为系统检测到没有 设置 MPVolumeView 就会自动添加
 */
// 添加系统音量view
- (void)addSystemVolumeView {
    [self.volumeView removeFromSuperview];
}

// 移除系统音量view
- (void)removeSystemVolumeView {
    [[UIApplication sharedApplication].keyWindow addSubview:self.volumeView];
}



#pragma mark - Private Method
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(applicationWillResignActive)
                                                  name:UIApplicationWillResignActiveNotification
                                                object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(applicationDidEnterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
}
// 添加手势
- (void)addGes {
    // 添加滑动手势
    UIPanGestureRecognizer *sliderGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    sliderGesture.delegate = self;
    [self addGestureRecognizer:sliderGesture];
    
    // 单击
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
     singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1; //手指数
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    // 双击(播放/暂停)
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTouchesRequired = 1; //手指数
    doubleTap.numberOfTapsRequired = 2;
    
    [self addGestureRecognizer:doubleTap];
    
    // 解决点击当前view时候响应其他控件事件
    [singleTap setDelaysTouchesBegan:YES];
    [doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
}


- (void)singleTapAction:(UITapGestureRecognizer *)gesture {
    if(self.player.playState == ZKPlayerPlayStateUnknown || self.player.playState == ZKPlayerPlayStatePlayFailed || self.player.playState == ZKPlayerPlayStatePlayStopped) return;
    [self singleTap];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)gesture {
    if(self.player.playState == ZKPlayerPlayStateUnknown || self.player.playState == ZKPlayerPlayStatePlayFailed || self.player.playState == ZKPlayerPlayStatePlayStopped) return;
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

- (void)handleSwipe:(UIPanGestureRecognizer *)swipe {
    if(self.player.playState == ZKPlayerPlayStateUnknown || self.player.playState == ZKPlayerPlayStatePlayFailed || self.player.playState == ZKPlayerPlayStatePlayStopped) return;
    
    CGPoint point = [swipe locationInView:self];
    // 移动方向
    ZKDirection type = [self getDirection:swipe];
    if (type == ZKDirectionUnknown && swipe.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    // 水平方向
    switch (swipe.state) {
        case UIGestureRecognizerStateBegan: {
            _panBeginPoint = point;
            if (self.player.totalTime != 0) {
                _panBeginTimeValue = self.player.currentTime / self.player.totalTime;
            }
            _panBeignVolumeValue =  [self volumeValue];
            _panBeginBrightnessValue = [[UIScreen mainScreen] brightness];
            [self gesturePanBeganDirection:type];
            NSLog(@" begin %f %f %f",_panBeginTimeValue,_panBeignVolumeValue, _panBeginBrightnessValue);
            
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (type == ZKDirectionProgress && self.player.totalTime != 0) {
                // 进度
                _panEndTimeValue = _panBeginTimeValue + ((point.x - _panBeginPoint.x) / self.bounds.size.width) * 0.3;
                _panEndTimeValue = MAX(MIN(_panEndTimeValue, 1), 0);
                [self gesturePanChangedDirection:type value:_panEndTimeValue];
                NSLog(@"进度value === %f", _panEndTimeValue);
                
            } else if (type == ZKDirectionVolume) {
                // 音量
                _panEndVolumeValue = _panBeignVolumeValue + ((_panBeginPoint.y - point.y) / self.bounds.size.height) * 0.3;
                _panEndVolumeValue = MAX(MIN(_panEndVolumeValue, 1), 0);
                self.player.volume = _panEndVolumeValue;
                NSLog(@"音量value === %f", _panEndVolumeValue);
                [self gesturePanChangedDirection:type value:_panEndVolumeValue];
                
            } else if (type == ZKDirectionBrightness) {
                // 亮度
                _panEndBrightnessValue = _panBeginBrightnessValue + ((_panBeginPoint.y - point.y) / self.bounds.size.height) * 0.3;
                _panEndBrightnessValue = MAX(MIN(_panEndBrightnessValue, 1), 0);
                NSLog(@"亮度value === %f", _panEndBrightnessValue);
               [[UIScreen mainScreen] setBrightness:_panEndBrightnessValue];
               [self gesturePanChangedDirection:type value:_panEndBrightnessValue];
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded: {
            CGFloat value = 0;
            if (type == ZKDirectionProgress && self.player.totalTime != 0) {
                value = _panEndTimeValue;
                
            } else if (type == ZKDirectionVolume) {
                value = _panEndVolumeValue;
                
            } else if (type == ZKDirectionBrightness) {
                value = _panEndBrightnessValue;
            }
            
            [self gesturePanEndDirection:type value:value];
            
            _panBeginTimeValue = -1;
            _panBeignVolumeValue = -1;
            _panBeginBrightnessValue = -1;
            _panEndTimeValue = -1;
            _panEndVolumeValue = -1;
            _panEndBrightnessValue = -1;
        }
            break;
        default:
            break;
    }
}

- (ZKDirection)getDirection:(UIPanGestureRecognizer *)swipe {
    CGPoint point = [swipe locationInView:self];
    CGPoint translation = [swipe translationInView:self];
    
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10) return ZKDirectionUnknown;
    
    if (absX > absY ) {
        NSLog(@"横向");
        return ZKDirectionProgress;
        
    } else if (absY > absX) {
        if (translation.y<0) {
            if (point.x < self.bounds.size.width / 2) {
                NSLog(@"亮度向上滑动");
                return ZKDirectionBrightness;
            } else {
                NSLog(@"音量向上滑动");
                return ZKDirectionVolume;
            }
            
        } else {
            if (point.x < self.bounds.size.width / 2) {
                NSLog(@"亮度向下滑动");
                return ZKDirectionBrightness;
            } else {
                NSLog(@"音量向下滑动");
                return ZKDirectionVolume;
            }
        }
    }
    return ZKDirectionUnknown;
}



#pragma mark - ZhikePlayerDelegate
/** 加载播放状态 */
- (void)zhikeVideo:(id)videoPlayer loadState:(ZKPlayerLoadState)state {
    NSLog(@"子类实现");
}
/** 播放状态 */
- (void)zhikeVideo:(id)videoPlayer playState:(ZKPlayerPlaybackState)state {
    NSLog(@"子类实现");
}
/** 播放进度 */
- (void)zhikeVideo:(id)videoPlayer playCurrentTime:(NSTimeInterval)currentTime playBufferTime:(NSTimeInterval)bufferTime durationTime:(NSTimeInterval)duration {
    NSLog(@"子类实现");
}


#pragma mark - 子类需要实现
- (void)gesturePanBeganDirection:(ZKDirection)direction {
    
}
- (void)gesturePanChangedDirection:(ZKDirection)direction value:(CGFloat)value {
    
}
- (void)gesturePanEndDirection:(ZKDirection)direction value:(CGFloat)value {
    
}

- (void)singleTap {
    
}

- (CGFloat)volumeValue {
    return 0;
}

#pragma mark LifeCycle
- (void)applicationWillEnterForeground {
}

- (void)applicationDidBecomeActive {
}

- (void)applicationWillResignActive {
}

- (void)applicationDidEnterBackground {
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

