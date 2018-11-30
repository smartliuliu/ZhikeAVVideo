//
//  ZhikeSlider.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKHeader.h"
#import "LargeButton.h"

@protocol ZKSliderViewDelegate <NSObject>

@optional
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value;
// 滑块滑动中
- (void)sliderValueChanged:(float)value;
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value;
// 滑杆点击
- (void)sliderTapped:(float)value;

@end

@interface ZKSliderButton : UIButton

@end


/** 进度条 */
@interface ZKSliderView : UIView

@property (nonatomic, weak) id<ZKSliderViewDelegate> delegate;

/** 滑块 */
@property (nonatomic, strong) LargeButton *sliderBtn;
/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;
/** 默认滑杆的图片 */
@property (nonatomic, strong) UIImage *maximumTrackImage;
/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 缓存进度的图片 */
@property (nonatomic, strong) UIImage *bufferTrackImage;
/** 滑杆进度 */
@property (nonatomic, assign) float value;
/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;

/** 是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL allowTapped;
/** 是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL animate;

/** 设置滑杆的高度 */
@property (nonatomic, assign) CGFloat sliderHeight;
/** 是否隐藏滑块（默认为NO） */
@property (nonatomic, assign) BOOL isHideSliderBlock;
/// 是否正在拖动
@property (nonatomic, assign) BOOL isdragging;
/// 向前还是向后拖动
@property (nonatomic, assign) BOOL isForward;

//@property (nonatomic, assign) CGFloat ignoreMargin;

// 设置滑块背景色
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 设置滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;



@end

