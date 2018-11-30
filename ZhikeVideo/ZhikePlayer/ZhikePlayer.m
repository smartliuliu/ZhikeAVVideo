//
//  ZhikePlayer.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/9.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+BundleImage.h"

@interface MyVideoPlayer : UIView

@end

@implementation MyVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end


static NSString *const kPlayRate   = @"rate";
static NSString *const kStatus  = @"status";
static NSString *const kPresentationSize = @"presentationSize";
static NSString *const kLoadedTimeRanges = @"loadedTimeRanges";
static NSString *const kPlaybackBufferEmpty = @"playbackBufferEmpty";
static NSString *const kPlaybackLikelyToKeepUp = @"playbackLikelyToKeepUp";

@interface ZhikePlayer() {
    BOOL  _isPreparedToPlay;
    CGFloat _volume;// 音量
    CGFloat _rate; // 倍速
    BOOL _muted; // 静音
    id _timeObserver;
    id _itemEndObserver;
}

@property (nonatomic,strong) UIImageView *bgImageView;

@property (strong, nonatomic)MyVideoPlayer *videoView;
@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic) AVURLAsset *myAsset;
@property (strong, nonatomic)AVPlayerItem *playerItem;//播放单元
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）
@property (nonatomic, assign) BOOL isBuffering;

@property (nonatomic, assign) CGFloat lastVolume; // 上一次的音量
@property(nonatomic,strong) AVPlayerItemVideoOutput *playerOutput;

@end

@implementation ZhikePlayer

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
        self.backgroundColor = [UIColor blackColor];
        _bgImageView = [[UIImageView alloc] init];
        _scalingMode = AVLayerVideoGravityResizeAspect;
        _rate = 1;
        _progressUpdateInterval = 250;
        _volume = 1;
    }
    
    return self;
}

#pragma mark - Public Method
#pragma mark LiftCycle
- (void)applicationWillEnterForeground {
    if(self.playInBackground) {
        _playerLayer.player = _myPlayer;
        if (self.bgImageView.superview) {
            [self.bgImageView removeFromSuperview];
        }
    }
}
- (void)applicationDidBecomeActive {
    
}
- (void)applicationWillResignActive {
    
}

- (void)applicationDidEnterBackground {
    if(self.playInBackground) {
        self.bgImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSubview:self.bgImageView];
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self thumbnailImageAtCurrentTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!image) {
                    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.coverImageUrl]
                                        placeholderImage:[UIImage getImage:@""]];
                } else {
                    self.bgImageView.image = image;
                }
            });
            
        });
        
        _playerLayer.player = nil;
    }
}

#pragma mark 播放器相关
// 播放
- (void)play {
    if (!_isPreparedToPlay) {
        [self prepareToPlay];
    } else {
        // 继续播放
        [self.myPlayer play];
        self.myPlayer.rate = self.rate;
        self.myPlayer.muted = self.muted;
        self.isPlaying = YES;
        self.playState = ZKPlayerPlayStatePlaying;
    }
}

// 暂停
- (void)pause {
    [self.myPlayer pause];
    self.isPlaying = NO;
    self.playState = ZKPlayerPlayStatePaused;
}

// 重新播放
- (void)replay {
    [self seekToTime:0 completionHandler:^(BOOL finished) {
        NSLog(@"重新播放");
        [self play];
    }];
}
- (void)reloadNowPlayer {
    self.seekTime = self.currentTime;
    [self prepareToPlay];
}

/** 准备播放 */
- (void)prepareToPlay {
    if (!_urlString) return;
    _isPreparedToPlay = YES;
    [self initializePlayer];
    self.loadState = ZKPlayerLoadStatePrepare;
    [self play];
}

/** seek */
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler {
    CMTime seekTime = CMTimeMake(time, 1);
    [_playerItem cancelPendingSeeks];
    [_myPlayer seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:completionHandler];
}



#pragma mark - Private Method
- (void)initializePlayer {
    // 是否是网络数据
    BOOL isNetwork = [self.urlString hasPrefix:@"http"];
    NSURL *url = [NSURL URLWithString:self.urlString];
    if (!isNetwork) {
        NSString *path = self.urlString;
        if(![self.urlString hasPrefix:@"file://"]) {
            path = [NSString stringWithFormat:@"file://%@", self.urlString];
        }
        url = [NSURL URLWithString:path];
    }

    _myAsset = [AVURLAsset assetWithURL:url];
    _playerItem = [AVPlayerItem playerItemWithAsset:_myAsset];
    _myPlayer = [AVPlayer playerWithPlayerItem:_playerItem];
    _myPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
    // fix回音
    _playerItem.audioTimePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
    for (AVPlayerItemTrack *track in _playerItem.tracks){
        if ([track.assetTrack.mediaType isEqual:AVMediaTypeVideo]) {
            track.enabled = YES;
        }
    }
    
    if (self.videoView.superview) {
        [self.videoView removeFromSuperview];
    }
    // 为了处理横屏，动态显示View
    MyVideoPlayer *videoView = [[MyVideoPlayer alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.videoView = videoView;
    videoView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.playerLayer = (AVPlayerLayer *)videoView.layer;
    [self.playerLayer setPlayer:self.myPlayer];
    [self addSubview:videoView];
    
    self.scalingMode = _scalingMode;
    if (@available(iOS 9.0, *)) {
        _playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = NO;
    }
    if (@available(iOS 10.0, *)) {
        _playerItem.preferredForwardBufferDuration = 1;
        _myPlayer.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    self.playerOutput = [[AVPlayerItemVideoOutput alloc] init];
    [self.playerItem addOutput:self.playerOutput];
    
    [self addObservers];
}


#pragma mark Add Observers
- (void)removePlayerItemObservers
{
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:kStatus];
        [_playerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
        [_playerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
        [_playerItem removeObserver:self forKeyPath:kLoadedTimeRanges];
        [_playerItem removeObserver:self forKeyPath:kPresentationSize];
        [_playerItem removeObserver:self forKeyPath:kPlayRate];
    }
}


- (void)addObservers {
    [self.playerItem addObserver:self
                      forKeyPath:kStatus
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:kPlaybackBufferEmpty
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:kPlaybackLikelyToKeepUp
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:kLoadedTimeRanges
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:kPresentationSize
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.playerItem addObserver:self
                      forKeyPath:kPlayRate
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    // tracking time,跟踪时间的改变
    CMTime interval = CMTimeMakeWithSeconds(_progressUpdateInterval / 1000, NSEC_PER_SEC);
    __weak typeof(self) weakSelf = self;
    _timeObserver = [self.myPlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSArray *loadedRanges = weakSelf.playerItem.seekableTimeRanges;
        if (loadedRanges.count) {
            [weakSelf updateDuration:time];
        }
        
    }];
    
    _itemEndObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        weakSelf.playState = ZKPlayerPlayStatePlayEnded;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionChangeObserver:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/** 通过KVO监控播放器状态
 * @param keyPath 监控属性
 * @param object 监视器
 * @param change 状态改变
 * @param context 上下文
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([keyPath isEqualToString:kStatus]) {
            if (self.myPlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                [self readyToPlay];
                
            } else if (self.myPlayer.currentItem.status == AVPlayerItemStatusFailed) {
                self.playState = ZKPlayerPlayStatePlayFailed;
                NSError *error = self.myPlayer.currentItem.error;
                NSLog(@"%@", error);
            }
        } else if ([keyPath isEqualToString:kPlaybackBufferEmpty]) {
            // buffer 空
            if (self.playerItem.playbackBufferEmpty) {
                self.loadState = ZKPlayerLoadStateStalled;
                [self bufferingSomeSecond];
            }
            
        } else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]) {
            // buffer 够
            if (self.playerItem.playbackLikelyToKeepUp) {
                self.loadState = ZKPlayerLoadStatePlayable;
            }
            
        } else if ([keyPath isEqualToString:kLoadedTimeRanges]) {
            if (self.isPlaying && self.playerItem.playbackLikelyToKeepUp){
                [self play];
            }
            NSTimeInterval bufferTime = [self availableDuration];
            self.bufferTime = bufferTime;
            if ([self.playDelegate respondsToSelector:@selector(zhikeVideo:playBufferTime:)]) {
                [self.playDelegate zhikeVideo:self playBufferTime:self.bufferTime];
            }
            
        } else if ([keyPath isEqualToString:kPresentationSize]) {
            NSLog(@"CGSize:  %@", NSStringFromCGSize(self.playerItem.presentationSize));
            //            self->_presentationSize = self.playerItem.presentationSize;
            
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    });
}



#pragma mark Observers Method
/** 耳机插拔 */
- (void)audioSessionChangeObserver:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    AVAudioSessionRouteChangeReason audioSessionRouteChangeReason = [userInfo[@"AVAudioSessionRouteChangeReasonKey"] longValue];
    AVAudioSessionInterruptionType audioSessionInterruptionType   = [userInfo[@"AVAudioSessionInterruptionTypeKey"] longValue];
    if (audioSessionRouteChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable){
        //插入耳机时关闭扬声器播放
        if (self.isPlaying) {
            [self.myPlayer play];
        }
    }
    if (audioSessionInterruptionType == AVAudioSessionInterruptionTypeEnded){
        if (self.isPlaying) {
            [self.myPlayer play];
        }
    }
  
    if (audioSessionRouteChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable){
        //拔出耳机时的处理为开启扬声器播放
        if (self.isPlaying) {
            [self.myPlayer play];
        }
        AVAudioSessionRouteDescription *routeDescription=userInfo[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            NSLog(@"Headphones");
        }
    }
}

/** 准备播放 */
- (void)readyToPlay {
    float duration = CMTimeGetSeconds(self.playerItem.asset.duration);
    if (isnan(duration)) {
        duration = 0.0;
    }
    self.totalTime = duration;
    
    self.loadState = ZKPlayerLoadStatePlaythroughOK;
    
    if (self.seekTime) {
        [self seekToTime:self.seekTime completionHandler:nil];
        self.seekTime = 0;
    }
    if(self.isPlaying){
        [self play];
        self.myPlayer.muted = self.muted;
        self.myPlayer.rate = self.rate;
    }
    
    NSArray *loadedRanges = self.playerItem.seekableTimeRanges;
    if (loadedRanges.count > 0) {
        
        [self.playDelegate zhikeVideo:self playCurrentTime:self.currentTime durationTime:self.totalTime];
    }
}

/**  缓冲较差时候回调这里 */
- (void)bufferingSomeSecond {
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    if (self.isBuffering) return;
    self.isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self.myPlayer pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (!self.isPlaying) {
            self.isBuffering = NO;
            return;
        }
        [self play];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        self.isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) [self bufferingSomeSecond];
    });
}

/** 缓冲时间 */
- (NSTimeInterval)availableDuration {
    NSArray *array=_playerItem.loadedTimeRanges;
    CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
    if (isnan(totalBuffer)) {
      totalBuffer = 0.0;
    }
    // NSLog(@"共缓冲：%.2f",totalBuffer);
    return totalBuffer;
}

/** 更新时间参数 */
- (void)updateDuration:(CMTime)time {
    self.currentTime = CMTimeGetSeconds(time);
    self.totalTime = CMTimeGetSeconds([self.playerItem duration]);
    NSLog(@"当前已经播放%.2fs.",self.currentTime);
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(zhikeVideo:playCurrentTime:durationTime:)]) {
        [self.playDelegate zhikeVideo:self playCurrentTime:self.currentTime durationTime:self.totalTime];
    }
}

// 停止播放器的所有工作
- (void)shutdown {
    [self removePlayerItemObservers];
    self.playState = ZKPlayerPlayStatePlayStopped;
    if (self.myPlayer) {
        if (self.myPlayer.rate != 0) [self.myPlayer pause];
        [self.myPlayer removeTimeObserver:_timeObserver];
        _myPlayer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:_itemEndObserver name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    _itemEndObserver = nil;
    _timeObserver = nil;
    _urlString = nil;
    _myAsset = nil;
    _playerItem = nil;
    if (_playerLayer) {
        [_playerLayer removeFromSuperlayer];
        _playerLayer = nil;
    }
    
    _playerOutput = nil;
    _isPlaying = NO;
    _isPreparedToPlay = NO;
    self.currentTime = 0;
    self.totalTime = 0;
    self.bufferTime = 0;
    if (self.videoView) {
        [self.videoView removeFromSuperview];
        self.videoView = nil;
    }
}

- (UIImage *)thumbnailImageAtCurrentTime {
    // mp4
    CMTime time = _playerItem.currentTime;
    AVAssetImageGenerator * gen = [[AVAssetImageGenerator alloc] initWithAsset:_myAsset];
    gen.appliesPreferredTrackTransform = YES;
    gen.requestedTimeToleranceAfter = kCMTimeZero;
    gen.requestedTimeToleranceBefore = kCMTimeZero;
    NSError * error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage * image = [[UIImage alloc] initWithCGImage:imageRef];
    if (image) {
        return image;
    }
    
    // m3u8
    CVPixelBufferRef pixelBuffer = [self.playerOutput copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage
                                                   fromRect:CGRectMake(0, 0,
                                                                       CVPixelBufferGetWidth(pixelBuffer),
                                                                       CVPixelBufferGetHeight(pixelBuffer))];
    UIImage *frameImg = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    //不释放会造成内存泄漏
    CVBufferRelease(pixelBuffer);
    return frameImg;
    
}


#pragma mark - Get
//- (BOOL)isPlaying {
//    if([[UIDevice currentDevice] systemVersion].intValue >= 10){
//        NSLog(@"%d",self.myPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying);
//        return self.myPlayer.timeControlStatus == AVPlayerTimeControlStatusPlaying;
//    }else{
//        NSLog(@"%f",self.myPlayer.rate);
//        return self.myPlayer.rate > 0;
//    }
//}

- (NSTimeInterval)totalTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.myPlayer.currentItem.duration);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}

- (NSTimeInterval)currentTime {
    NSTimeInterval sec = CMTimeGetSeconds(self.playerItem.currentTime);
    if (isnan(sec)) {
        return 0;
    }
    return sec;
}


#pragma mark - Set
- (void)setVolume:(CGFloat)volume {
    _volume = MIN(MAX(0, volume), 1);
//    if(self.myPlayer) {
//        self.myPlayer.volume = volume;
//    }
}

- (void)setRate:(CGFloat)rate {
    _rate = rate;
    if (self.myPlayer && fabsf(_myPlayer.rate) > 0.00001f) {
        self.myPlayer.rate = rate;
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    if (self.myPlayer) {
        self.myPlayer.muted = muted;
    }
}

- (void)setPlayState:(ZKPlayerPlaybackState)playState {
    _playState = playState;
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(zhikeVideo:playState:)]) {
        [self.playDelegate zhikeVideo:self playState:_playState];
    }
}

- (void)setLoadState:(ZKPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playDelegate && [self.playDelegate respondsToSelector:@selector(zhikeVideo:loadState:)]) {
        [self.playDelegate zhikeVideo:self loadState:_loadState];
    }
}

- (void)setUrlString:(NSString *)urlString {
    if(_urlString.length && ![_urlString isEqualToString:urlString]){
        if (self.myPlayer) [self shutdown];
    }
    _urlString = urlString;
}

- (void)setScalingMode:(AVLayerVideoGravity)scalingMode {
    _scalingMode = scalingMode;
    self.playerLayer.videoGravity = scalingMode;
}


- (void)dealloc {
    [self shutdown];
}


@end



