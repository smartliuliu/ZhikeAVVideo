//
//  ZhikePlayGesBaseView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/14.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ZhikePlayer.h"

typedef NS_ENUM(NSInteger, ZKDirection) {
    ZKDirectionUnknown, // 未移动（现在如果x,yj间距为5，视为未移动）
    ZKDirectionBrightness, // 亮度
    ZKDirectionVolume, // 音量向下
    ZKDirectionProgress, // 进度
};

/** 手势层级的 */
@interface ZhikePlayGesBaseView : UIView<ZhikePlayerDelegate> {
    BOOL _isPlaying;
}

#pragma mark 与子类公用
// 播放器内核
@property (nonatomic, strong) ZhikePlayer *player;
// 是否正在播放
@property (nonatomic, assign) BOOL isPlaying;
// 总时间
@property (nonatomic, assign) CGFloat durationTime;
// 是否处于后台
@property (nonatomic, assign) BOOL isBackground;
@property (nonatomic, strong) MPVolumeView *volumeView;



#pragma mark  - Public Method
/** 添加系统音量view */
- (void)addSystemVolumeView;
/**  移除系统音量view */
- (void)removeSystemVolumeView;


#pragma mark - 子类需要重写
/** 拖动手势*/
- (void)gesturePanBeganDirection:(ZKDirection)direction;
- (void)gesturePanChangedDirection:(ZKDirection)direction value:(CGFloat)value;
- (void)gesturePanEndDirection:(ZKDirection)direction value:(CGFloat)value;
/** 单击 */
- (void)singleTap;
- (CGFloat)volumeValue;

/** 前后台切换*/
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;

@end


