//
//  ZhikePlayerControlBar.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "ZKSliderView.h"

typedef NS_ENUM(NSInteger, BottomClickType) {
    BOTTOM_LANDSCAPE, // 全屏
    BOTTOM_PORTRAIT, // 竖屏
    BOTTOM_PLAY, // 播放
    BOTTOM_PAUSE, //暂停
    BOTTOM_RATE, // 倍速
    BOTTOM_SMOOTH // 清晰度
};

@protocol ZKPlayerBottomBarDelegate <NSObject>

- (void)bottomClickBtn:(id)btn type:(BottomClickType)type;

@end

/** 底部控制View */
@interface ZhikePlayerBottomBar : UIView

@property (nonatomic, weak) id<ZKPlayerBottomBarDelegate> delegate;

@property (nonatomic, strong) UIView *containView;
/** 播放的当前时间 */
@property (nonatomic, strong) UILabel *currentTimeLabel;
/** 滑杆 */
@property (nonatomic, strong) ZKSliderView *sliderView;
/** 视频总时间 */
@property (nonatomic, strong) UILabel *totalTimeLabel;
/** 倍速数组
 * 如果不想横屏出现"倍速"，则这个数组为空
 */
@property (nonatomic, strong) NSArray *ratesArray;
/** 清晰度数组
 * 如果不想横屏出现"清晰度"，则这个数组为空
 */
@property (nonatomic, strong) NSArray *smoothArray;
/** 当前倍速index */
@property (nonatomic, assign) NSInteger rateIndex;
/** 当前清晰度index */
@property (nonatomic, assign) NSInteger smoothIndex;


@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isFullScreen;

- (void)isHiddenControl:(BOOL)isHidden animateComplete:(void (^ __nullable)(BOOL finished))completion;

/** 改变清晰度和倍速的bottom名称 */
- (void)changeLandName;
@end

