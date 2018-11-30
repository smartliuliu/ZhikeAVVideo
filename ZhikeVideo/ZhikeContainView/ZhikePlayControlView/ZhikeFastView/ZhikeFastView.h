//
//  ZhikeFastView.h
//  ZhikeAVVideo
//
//  Created by liu on 2018/11/26.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKSliderView.h"

@interface ZhikeFastView : UIView

/** 快进快退时间 */
@property (nonatomic, strong) UILabel *fastTimeLabel;
/** 快进快退进度progress */
@property (nonatomic, strong) ZKSliderView *fastProgressView;
@property (nonatomic, copy) NSString *timeText;

@end

