//
//  ZhikeOrientation.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/15.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikeOrientation.h"

@implementation ZhikeOrientation

static UIInterfaceOrientationMask _orientation = UIInterfaceOrientationMaskAllButUpsideDown;

+ (void)setOrientation: (UIInterfaceOrientationMask)orientation {
    _orientation = orientation;
}

+ (UIInterfaceOrientationMask)getOrientation {
    return _orientation;
}


/* 强制屏幕转屏
 * orientation: 屏幕方向
 */
+ (void)changeOrientation:(UIInterfaceOrientation)orientation {
    // arc下
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector             = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val                  = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

+ (void)lockToPortrait {
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskPortrait];
    [ZhikeOrientation changeOrientation:UIInterfaceOrientationPortrait];
}

+ (void)lockToLandscape {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskLandscape];
     if (orientation == UIDeviceOrientationLandscapeLeft) {
        [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeRight];
    } else {
        [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeLeft];
    }
}

+ (void)lockToLandscapeLeft {
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskLandscapeLeft];
    [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeLeft];
}
        
+ (void)lockToLandscapeRight {
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskLandscapeRight];
    [ZhikeOrientation changeOrientation:UIInterfaceOrientationLandscapeRight];
}

+ (void)unlockAllOrientations {
    [ZhikeOrientation setOrientation:UIInterfaceOrientationMaskAllButUpsideDown];
}

@end
