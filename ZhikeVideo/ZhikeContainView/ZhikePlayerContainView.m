//
//  ZhikePlayerContainView.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayerContainView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZhikePlayControlView.h"
#import "ZhikeOrientation.h"
#import "ZKSpeedLoadingView.h"
#import "ZhikePlayLandView.h"
#import "ZhikeBrightnessView.h"
#import "ZhikeFastView.h"

@interface ZhikePlayerContainView()<ZKSliderViewDelegate, ZKPlayerBottomBarDelegate> {
    BOOL _enterBackIsPlaying;
    BOOL _isEnter;
    BOOL _isEnd;
}

/** 第一次进入的 frame */
@property (nonatomic, assign) CGRect lastRect;
/** 第一次进入的 方向 */
@property (nonatomic, assign) UIInterfaceOrientation lastOrientation;
/** 控制进度的View */
@property (nonatomic, strong) ZhikePlayControlView *controlView;
/** loading */
@property (nonatomic, strong) ZKSpeedLoadingView *loadingView;
/** 加载失败按钮 */
@property (nonatomic, strong) LargeButton *failBtn;
/** 封面图 */
@property (nonatomic, strong) UIImageView *coverImageView;
/** 横屏显示的倍速 */
@property (nonatomic, strong) ZhikePlayLandView *rateView;
/** 横屏显示的清晰度 */
@property (nonatomic, strong) ZhikePlayLandView *smoothView;
/** 声音滑杆 */
@property (nonatomic, strong) UISlider *volumeViewSlider;
/** 快进 */
@property (nonatomic, strong) ZhikeFastView *fastView;

@end

@implementation ZhikePlayerContainView

- (void)drawRect:(CGRect)rect {
    if (self.isOnlyFullScreen) {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        CGFloat width = MAX(size.width, size.height);
        CGFloat height = MIN(size.width, size.height);
        
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(width, height));
            make.bottom.and.left.mas_equalTo(0);
        }];
    }
}

- (void)didMoveToSuperview {
    if (_isEnter) {
        return;
    }
    _isEnter = YES;
    UIInterfaceOrientation orientation = [self getStatusBarOrientation];
    if (_isOnlyFullScreen) {
        BOOL isLandScape = (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight);
        if (!isLandScape) {
            [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskLandscape];
            [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeRight];
        }
        [self setContainFrame:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterFullScreen:)]) {
            [self.delegate zhikePlayerEnterFullScreen:self];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterPortrait:)]) {
            [self.delegate zhikePlayerEnterPortrait:self];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _urlString = @"";
        self.lastOrientation = [self getStatusBarOrientation];
        [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
        [self configureVolume];
        
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.controlView];
        [self addSubview:self.fastView];
        [self addSubview:self.loadingView];
        [self addSubview:self.failBtn];
        [self addSubview:self.smoothView];
        [self addSubview:self.rateView];
        
        // 为了出现播放按钮
        [self.controlView insertSubview:self.coverImageView atIndex:0];
        
        [self.controlView.topBarView.backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.player);
        }];
        
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.controlView);
        }];
        
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(kScalePhone6Value(10));
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
        [self.failBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(150, 30));
        }];
        
        [self.rateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.fastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.mas_width).dividedBy(3);
            make.height.mas_equalTo(kScalePhone6Value(40));
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(-20);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    
    return self;
}



#pragma mark - Get
- (ZhikePlayControlView *)controlView {
    if (!_controlView) {
        _controlView = [[ZhikePlayControlView alloc] init];
        _controlView.bottomBarView.sliderView.delegate = self;
        _controlView.bottomBarView.delegate = self;
        [_controlView.centerPlayBtn addTarget:self action:@selector(playCenterClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _controlView;
}

- (ZKSpeedLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[ZKSpeedLoadingView alloc] init];
        _loadingView.hidden = YES;
    }
    
    return _loadingView;
}

- (LargeButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [LargeButton buttonWithType:UIButtonTypeSystem];
        _failBtn.dx = -20;
        _failBtn.dy = -20;
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn addTarget:self action:@selector(failBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _failBtn.hidden = YES;
    }
    return _failBtn;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImageView;
}

- (ZhikePlayLandView *)rateView {
    if (!_rateView) {
        _rateView = [[ZhikePlayLandView alloc] init];
        __weak typeof(self) weakSelf = self;
        _rateView.clickBtnBlock = ^(UIView *view, NSInteger index) {
            weakSelf.rateIndex = index;
            [weakSelf.controlView.bottomBarView changeLandName];
            //            if(weakSelf.player.isPlaying) {
            [weakSelf playVideo];
            [weakSelf.controlView changeIsShowBottomView: YES];
            //            }
        };
        _rateView.hidden = YES;
    }
    
    return _rateView;
}

- (ZhikePlayLandView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[ZhikePlayLandView alloc] init];
        __weak typeof(self) weakSelf = self;
        _smoothView.clickBtnBlock = ^(UIView *view, NSInteger index) {
            weakSelf.smoothIndex = index;
            [weakSelf.controlView.bottomBarView changeLandName];
            //            if(weakSelf.player.isPlaying) {
            [weakSelf playVideo];
            [weakSelf.controlView changeIsShowBottomView: YES];
            //            }
        };
        _smoothView.hidden = YES;
    }
    
    return _smoothView;
}

- (ZhikeFastView *)fastView {
    if (!_fastView) {
        _fastView = [[ZhikeFastView alloc] init];
        _fastView.hidden = YES;
    }
    
    return _fastView;
}



#pragma mark Get Method
/** 中心播放按钮点击事件 */
- (void)playCenterClick:(UIButton *)btn {
    self.isPlaying = !self.controlView.centerPlayBtn.isSelected;
    if (self.isPlaying) {
      if(_isEnd){
        [self replayVideo];
      } else {
         [self playVideo];
      }
    } else {
        [self.player pause];
    }
}

- (void)failBtnClick {
    [self.player reloadNowPlayer];
}

#pragma mark - Set
- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    self.player.urlString = urlString;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    if (_isPlaying == isPlaying) {
        return;
    }
    _isPlaying = isPlaying;
    self.controlView.isPlaying =_isPlaying;
}

- (void)setCoverImageUrl:(NSString *)coverImageUrl {
    _coverImageUrl = coverImageUrl;
    self.player.coverImageUrl = coverImageUrl;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:_coverImageUrl]
                           placeholderImage:[UIImage getImage:@""]];
}

- (void)setShouldAutorotate:(BOOL)shouldAutorotate {
    _shouldAutorotate = shouldAutorotate;
    if (_shouldAutorotate) {
        [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
    } else {
        [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskPortrait];
    }
}

- (void)setRatesArray:(NSArray *)ratesArray {
    _ratesArray = ratesArray;
    self.controlView.bottomBarView.ratesArray = _ratesArray;
    self.rateView.containArray = _ratesArray;
}

- (void)setSmoothArray:(NSArray *)smoothArray {
    _smoothArray = smoothArray;
    self.controlView.bottomBarView.smoothArray = _smoothArray;
    self.smoothView.containArray = _smoothArray;
}

- (void)setRateIndex:(NSInteger)rateIndex {
    _rateIndex = rateIndex;
    self.controlView.bottomBarView.rateIndex = _rateIndex;
    self.rateView.selectedIndex = _rateIndex;
}

- (void)setSmoothIndex:(NSInteger)smoothIndex {
    _smoothIndex = smoothIndex;
    self.controlView.bottomBarView.smoothIndex = _smoothIndex;
    self.smoothView.selectedIndex = _smoothIndex;
}


- (void)setPlayInBackground:(BOOL)playInBackground {
    _playInBackground = playInBackground;
    self.player.playInBackground = playInBackground;
}

- (void)setVideoTitle:(NSString *)videoTitle {
    _videoTitle = videoTitle;
    self.controlView.topBarView.videoTitle = videoTitle;
}

- (void)setIsOnlyFullScreen:(BOOL)isOnlyFullScreen {
    _isOnlyFullScreen = isOnlyFullScreen;
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    self.player.muted = muted;
}

- (void)setSeekTime:(CGFloat)seekTime {
    _seekTime = seekTime;
    self.player.seekTime = seekTime;
}

- (void)setScalingMode:(AVLayerVideoGravity)scalingMode {
    _scalingMode = scalingMode;
    self.player.scalingMode = _scalingMode;
}



#pragma mark - ZKSliderViewDelegate
- (void)sliderTouchBegan:(float)value {
    self.fastView.hidden = NO;
    self.controlView.bottomBarView.sliderView.isdragging = YES;
}

- (void)sliderValueChanged:(float)value {
    // 滑动条
    [self.controlView cancelAutoFadeOutControlView];
    if (self.player.totalTime == 0) {
        self.controlView.bottomBarView.sliderView.value = 0;
        return;
    }
    self.controlView.bottomBarView.sliderView.isdragging = YES;
    self.controlView.bottomBarView.sliderView.value = value;
    NSString *currentTimeString = [self convertTimeSecond:self.player.totalTime * value isHour:YES];
    self.controlView.bottomBarView.currentTimeLabel.text = currentTimeString;
    
    // 快进
    NSString *showCurrentTime = [self convertTimeSecond:self.player.totalTime * value isHour:NO];
    NSString *totalTimeString = [self convertTimeSecond:self.player.totalTime isHour:NO];
    self.fastView.hidden = NO;
    self.fastView.fastProgressView.value = value;
    self.fastView.timeText = [NSString stringWithFormat:@"%@/%@", showCurrentTime, totalTimeString];
    
    // 滑动的过程中按钮变大
    [UIView animateWithDuration:0.2 animations:^{
        self.controlView.bottomBarView.sliderView.sliderBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

- (void)sliderTouchEnded:(float)value {
    self.fastView.hidden = YES;
    if (self.player.totalTime > 0) {
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:self.player.totalTime * value completionHandler:^(BOOL finished) {
            if (finished) {
                weakSelf.controlView.bottomBarView.sliderView.isdragging = NO;
                //                if(weakSelf.player.isPlaying) {
                [weakSelf playVideo];
                //                }
                
            }
        }];
        
        // 滑动结束恢复size
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.controlView.bottomBarView.sliderView.sliderBtn.transform = CGAffineTransformIdentity;
        }];
        
    } else {
        self.controlView.bottomBarView.sliderView.isdragging = NO;
    }
    [self.controlView autoFadeOutControlView];
}

- (void)sliderTapped:(float)value {
    [self.controlView cancelAutoFadeOutControlView];
    if (self.player.totalTime > 0) {
        self.controlView.bottomBarView.sliderView.isdragging = YES;
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:self.player.totalTime * value completionHandler:^(BOOL finished) {
            if (finished) {
                weakSelf.controlView.bottomBarView.sliderView.isdragging = NO;
                //                if(weakSelf.player.isPlaying) {
                [weakSelf playVideo];
                [weakSelf.controlView autoFadeOutControlView];
                //                }
            }
        }];
    } else {
        self.controlView.bottomBarView.sliderView.isdragging = NO;
        self.controlView.bottomBarView.sliderView.value = 0;
    }
}

#pragma mark - ZKPlayerBottomBarDelegate
- (void)bottomClickBtn:(id)btn type:(BottomClickType)type {
  switch (type) {
    case BOTTOM_LANDSCAPE:
    {
      if (self.lastRect.size.width == 0) {
        self.lastRect = self.frame;
      }
      NSLog(@"全屏 %@", NSStringFromCGRect(_lastRect));
      [self clickIsFullScreenOrientation:YES];
      [self.controlView changeIsShowBottomView:YES];
    }
      break;
    case BOTTOM_PORTRAIT:
    {
      NSLog(@"竖屏");
      [self clickIsFullScreenOrientation:NO];
      [self.controlView changeIsShowBottomView:YES];
    }
      break;
      
    case BOTTOM_PLAY:
    {
      NSLog(@"播放");
      self.isPlaying = YES;
      if(_isEnd) {
        [self replayVideo];
      } else {
        [self playVideo];
      }
      
    }
      break;
    case BOTTOM_PAUSE:
    {
      NSLog(@"暂停");
      self.isPlaying = NO;
      [self.player pause];
    }
      break;
    case BOTTOM_RATE:
    {
      NSLog(@"倍速");
      [self.controlView changeIsShowBottomView:NO];
      [self.rateView showLandView:YES];
    }
      break;
    case BOTTOM_SMOOTH:
    {
      NSLog(@"清晰度");
      [self.controlView changeIsShowBottomView:NO];
      [self.smoothView showLandView:YES];
    }
      break;
      
    default:
      break;
  }
}



#pragma mark - ZhikePlayerDelegate
- (void)zhikeVideo:(id)videoPlayer loadState:(ZKPlayerLoadState)state {
    //    ZKPlayerLoadStateUnknown = 0,
    //    ZKPlayerLoadStatePrepare,         // 调用开始播放（不一定成功）
    //    ZKPlayerLoadStatePlayDidChange,   // 准备开始播放了
    //    ZKPlayerLoadStatePlayable,       // 加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全
    //    ZKPlayerLoadStatePlaythroughOK, // 加载完成，即将播放
    //    ZKPlayerLoadStateStalled , // 可能由于网速不好等因素导致了暂停
    if (state == ZKPlayerLoadStatePrepare) {
        // 调用播放器
        self.coverImageView.hidden = NO;
    } else if(state == ZKPlayerLoadStatePlaythroughOK){
        // 准备开始播放了
        self.durationTime = self.player.totalTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerDurationTime:sender:)]) {
            [self.delegate zhikePlayerDurationTime:self.player.totalTime sender:self];
        }
        self.coverImageView.hidden = YES;
        [self.coverImageView removeFromSuperview];
        [self.controlView changeIsShowBottomView:YES];
    }
    
    if (state == ZKPlayerLoadStateStalled || state == ZKPlayerLoadStatePrepare) {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
}

- (void)zhikeVideo:(id)videoPlayer playState:(ZKPlayerPlaybackState)state {
    //    ZKPlayerPlayStateUnknown = 0,
    //    ZKPlayerPlayStatePlaying,
    //    ZKPlayerPlayStatePaused,
    //    ZKPlayerPlayStatePlayFailed, // 播放出现错误
    //    ZKPlayerPlayStatePlayStopped, // todo zl  播放停止
    //    ZKPlayerPlayStatePlayEnded, // 播放结束
    //    ZKPlayerPlayStatePlayUserExited // 用户退出播放
    //    ZKPlayerPlayStatePlayInterrupted, // 播放中止

    self.failBtn.hidden = YES;
    if (state == ZKPlayerPlayStatePlaying) {
       self.isPlaying = _isEnd ? NO :YES;
      
    } else if (state == ZKPlayerPlayStatePlayEnded) {
        NSLog(@"播放结束 end");
        _isEnd = YES;
        self.seekTime = 0;
        self.isPlaying = NO;
        [self.rateView showLandView:NO];
        [self.smoothView showLandView:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerPlayEnded:)]) {
            [self.delegate zhikePlayerPlayEnded:self];
        }
        
    } else if (state == ZKPlayerPlayStatePlayFailed) {
        NSLog(@"播放出现错误");
        self.failBtn.hidden = NO;
        self.isPlaying = NO;
        [self.loadingView stopAnimating];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerPlayFailed:)]) {
            [self.delegate zhikePlayerPlayFailed:self];
        }
        
    } else if (state == ZKPlayerPlayStatePlayInterrupted) {
        NSLog(@"播放中止");
        self.isPlaying = NO;
    }
}

- (void)zhikeVideo:(id)videoPlayer playCurrentTime:(NSTimeInterval)currentTime durationTime:(NSTimeInterval)duration {
    // todo zl 我删除试试
    //    self.durationTime = duration;
    if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerCurrentTime:sender:)]) {
        [self.delegate zhikePlayerCurrentTime:currentTime sender:self];
    }
    
    if (!self.controlView.bottomBarView.sliderView.isdragging && self.durationTime > 0) {
        
        NSString *currentTimeString = [self convertTimeSecond:currentTime isHour:YES];
        NSString *totalTimeString = [self convertTimeSecond:duration isHour:YES];
        
        self.controlView.bottomBarView.currentTimeLabel.text = currentTimeString;
        
        self.controlView.bottomBarView.totalTimeLabel.text = totalTimeString;
        //        NSLog(@"%f %f", currentTime/duration, bufferTime/duration);
        self.controlView.bottomBarView.sliderView.value = currentTime/duration;
    }
}

- (void)zhikeVideo:(id)videoPlayer playBufferTime:(NSTimeInterval)bufferTime {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerBufferTime:sender:)]) {
        [self.delegate zhikePlayerBufferTime:bufferTime sender:self];
    }
    if (!self.controlView.bottomBarView.sliderView.isdragging && self.durationTime > 0) {
        self.controlView.bottomBarView.sliderView.bufferValue = bufferTime/self.durationTime;
    }
}



#pragma mark - 手势
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    // 底部bottom top 屏蔽 view滑动手势
    if ([touch.view isDescendantOfView:self.controlView.bottomBarView.containView] || [touch.view isDescendantOfView:self.controlView.topBarView.backBtn]) {
        return NO;
    }
    
    if ([touch.view isDescendantOfView:self.rateView] || [touch.view isDescendantOfView:self.smoothView]) {
        return NO;
    }
    
    return YES;
}



#pragma mark - 父类方法
#pragma mark 移动手势
- (void)gesturePanBeganDirection:(ZKDirection)direction {
    if (direction == ZKDirectionProgress) {
        // value 这里没用，给0即可
        [self sliderTouchBegan:0];
    } else {
        self.fastView.hidden = YES;
    }
}
- (void)gesturePanChangedDirection:(ZKDirection)direction value:(CGFloat)value {
    if (direction == ZKDirectionProgress) {
        [self sliderValueChanged:value];
    } else if (direction == ZKDirectionVolume) {
        // todo zl声音
        self.volumeViewSlider.value = value;
    }
    
}
- (void)gesturePanEndDirection:(ZKDirection)direction value:(CGFloat)value {
    self.fastView.hidden = YES;
    if (direction == ZKDirectionProgress) {
        [self sliderTouchEnded:value];
    }
}

/** 单击 */
- (void)singleTap {
    [self.controlView changeIsShowBottomView:!self.controlView.isShowControlView];
}

- (CGFloat)volumeValue {
    return self.volumeViewSlider.value;
}

#pragma mark  LifeCycle
- (void)applicationWillEnterForeground {
    self.isPlaying = self.player.isPlaying;
    if (_enterBackIsPlaying) {
        // 进入前台要播放
        if(!self.playInBackground){
            [self.player play];
            self.isPlaying = YES;
        } else {
            [self.player applicationWillEnterForeground];
        }
    }
}

- (void)applicationDidBecomeActive {
    self.isBackground = NO;
    if (!self.shouldAutorotate || self.isOnlyFullScreen) {
        return;
    }
    
    // 进入前台解锁
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
}

- (void)applicationWillResignActive {
    // 记录进入后台的播放状态
    _enterBackIsPlaying = self.player.isPlaying;
    self.isBackground = YES;
    
    if(_enterBackIsPlaying){
        if (!self.playInBackground){
            [self.player pause];
        } else {
            [self.player applicationWillResignActive];
        }
    }
    
    // 进入后台锁屏
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIInterfaceOrientationMask isLand = UIInterfaceOrientationMaskPortrait;
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        isLand = UIInterfaceOrientationMaskLandscape;
    }
    [ZhikeOrientation setOrientation:isLand];
}

- (void)applicationDidEnterBackground {
    if(_enterBackIsPlaying){
        [self.player applicationDidEnterBackground];
    }
}


#pragma mark - Private Method
// 设置横竖屏
- (void)clickIsFullScreenOrientation:(BOOL)isFull {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (isFull) {
        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            if (!self.shouldAutorotate || self.isOnlyFullScreen) {
                [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskLandscape];
                if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterFullScreen:)]) {
                    [self.delegate zhikePlayerEnterFullScreen:self];
                }
            }
            [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeRight];
            [UIView animateWithDuration:0.2 animations:^{
                [self setContainFrame:YES];
            }];
            
        }
    } else {
        UIInterfaceOrientationMask type = UIInterfaceOrientationMaskPortrait;
        if (!self.shouldAutorotate || self.isOnlyFullScreen) {
            [ZhikeOrientation setOrientation:type];
            if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterPortrait:)]) {
                [self.delegate zhikePlayerEnterPortrait:self];
            }
        }
        
        [ZhikeOrientation changeOrientation:UIInterfaceOrientationPortrait];
        [self setContainFrame:NO];
        NSLog(@"全屏 %@", NSStringFromCGRect(self.lastRect));
    }
    
}

// 设置全屏和竖屏自身的frame
- (void)setContainFrame:(BOOL)isFull {
    NSLog(@" size :%@",NSStringFromCGSize([[UIScreen mainScreen] bounds].size));
    self.controlView.bottomBarView.isFullScreen = isFull;
    if (isFull) {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo([[UIScreen mainScreen] bounds].size);
            make.bottom.and.left.mas_equalTo(0);
        }];
        
        [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.top.mas_equalTo(0);
            make.left.mas_equalTo(kIS_PhoneXAll ? kStatusHeight : 0);
            make.right.mas_equalTo(-kSafeAreaInsetsBottom);
        }];
        
    } else {
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.lastRect.origin.x);
            make.top.mas_equalTo(self.lastRect.origin.y);
            make.size.mas_equalTo(self.lastRect.size);
        }];
        
        [self.player mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    
    [self setNeedsLayout];
}

// 返回按钮
- (void)backClick {
    if (self.controlView.bottomBarView.isFullScreen && !self.isOnlyFullScreen) {
        [self clickIsFullScreenOrientation:NO];
        [self.controlView changeIsShowBottomView:YES];
    } else {
        
        if (self.player) {
            [self.player shutdown];
        }
        
        BOOL enterIsLandscape = self.lastOrientation == UIInterfaceOrientationLandscapeLeft || self.lastOrientation == UIInterfaceOrientationLandscapeRight;
        BOOL isNowLandscape = self.controlView.bottomBarView.isFullScreen;
        // 回到最初的 屏幕方向
        if (enterIsLandscape != isNowLandscape) {
            UIInterfaceOrientationMask type = enterIsLandscape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
            // 防止横屏变竖屏 闪动
            self.alpha = 0;
            if (!self.shouldAutorotate || self.isOnlyFullScreen) {
                [ZhikeOrientation setOrientation:type];
            }
            [ZhikeOrientation changeOrientation:self.lastOrientation];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerBack:)]) {
            [self.delegate zhikePlayerBack:self];
        }
    }
}

// 获取StatusBar方向
- (UIInterfaceOrientation)getStatusBarOrientation{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortraitUpsideDown || orientation == UIInterfaceOrientationUnknown) {
        orientation = UIInterfaceOrientationPortrait;
    }
    
    return orientation;
}

#pragma mark - 系统音量相关
/**
 *  获取系统音量
 */
- (void)configureVolume {
    self.volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [self.volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}



#pragma mark - deviceOrientationDidChange
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    if (self.lastRect.size.width == 0) {
        self.lastRect = self.frame;
    }
    
    if (!_isOnlyFullScreen && self.shouldAutorotate && !self.isBackground) {
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        //         UIInterfaceOrientation orientation2 = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || orientation == UIDeviceOrientationPortraitUpsideDown) {
            return;
        }
        
        BOOL isLandScape = (orientation == UIDeviceOrientationPortrait) ? NO : YES;
        [self.rateView showLandView:NO];
        [self.smoothView showLandView:NO];
        [self setContainFrame:isLandScape];
        if (isLandScape) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterFullScreen:)]) {
                [self.delegate zhikePlayerEnterFullScreen:self];
            }
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(zhikePlayerEnterPortrait:)]) {
                [self.delegate zhikePlayerEnterPortrait:self];
            }
        }
    }
}


#pragma mark - Public Method
- (void)teardownPlayer {
    self.isPlaying = NO;
    [self.player shutdown];
}

// 暂停
- (void)pausedVideo {
    self.isPlaying = NO;
    [self.player pause];
}

/** 重新播放(从0开始当前视频) */
- (void)replayVideo {
  self.seekTime = 0;
  self.isPlaying = YES;
  _isEnd = NO;
  [self.player replay];
}

// 播放 视频
- (void)playVideo {
    self.isPlaying = YES;
    // 当前播放的时间
    CGFloat nowTime = self.player.currentTime;
    if (self.seekTime) {
        nowTime = self.seekTime;
    }
    
    // 播放到结尾，从seektime播放
    if (_isEnd) {
        nowTime = self.seekTime > 0 ? self.seekTime : 0;
        _isEnd = NO;
    }
    
    if (self.seekTime || _isEnd) {
        _seekTime = 0;
    }
    
    
    // 当前播视频源
    NSString *nowUrl = @"";
    if (self.smoothArray && self.smoothArray.count) {
        nowUrl = [self.smoothArray[self.smoothIndex] objectForKey:@"playUrl"];
    }
    // 是否是新的视频源
    BOOL isNewPlay = NO;
    if (self.urlString.length && nowUrl.length && ![self.urlString isEqualToString:nowUrl]) {
        isNewPlay = YES;
    }
    
    if (nowUrl.length) {
        self.urlString = nowUrl;
    }
    
    // 当前播放的倍速
    if (self.ratesArray &&  self.ratesArray.count) {
        CGFloat rate = [[NSString stringWithFormat:@"%@",self.ratesArray[self.rateIndex]] floatValue];
        self.player.rate = rate;
    }
    
    if (self.urlString) {
        if (isNewPlay) {
            self.player.seekTime = nowTime;
        }
        [self.player play];
    }
}



#pragma mark - Tools
- (NSString *)convertTimeSecond:(CGFloat)timeSecond isHour:(BOOL)isShow{
    NSString *theLastTime = nil;
    NSString *sign = isShow ? @"00:" : @"";
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"%@00:%02zd", sign, second];
    } else if(timeSecond >= 60 && timeSecond < 3600){
        theLastTime = [NSString stringWithFormat:@"%@%02zd:%02zd",sign, second / 60, second % 60];
    } else if(timeSecond >= 3600){
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second / 3600, second % 3600 / 60, second % 60];
    }
    return theLastTime;
}



- (void)layoutSubviews {
    [super layoutSubviews];
    [ZhikeBrightnessView sharedBrightnessView].center = CGPointMake([[UIScreen mainScreen] bounds].size.width / 2, [[UIScreen mainScreen] bounds].size.height /2);
}

@end





