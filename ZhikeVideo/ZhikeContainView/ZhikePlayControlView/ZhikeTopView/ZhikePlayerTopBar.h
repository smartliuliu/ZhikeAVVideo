//
//  ZhikePlayerTopBar.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LargeButton.h"
#import "UIImage+BundleImage.h"

/** 顶部控制View */
@interface ZhikePlayerTopBar : UIView

/** 返回按钮 */
@property (nonatomic, strong) LargeButton *backBtn;
/** 视频标题 */
@property (nonatomic, strong) NSString *videoTitle;

- (void)isHiddenControl:(BOOL)isHidden animateComplete:(void (^ __nullable)(BOOL finished))completion;

@end


