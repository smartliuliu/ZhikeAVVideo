//
//  ZhikeOrientation.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/15.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZhikeOrientation : NSObject

+ (void)setOrientation: (UIInterfaceOrientationMask)orientation;
+ (UIInterfaceOrientationMask)getOrientation;

+ (void)changeOrientation:(UIInterfaceOrientation)orientation;

+ (void)lockToPortrait;

+ (void)lockToLandscape;

+ (void)lockToLandscapeLeft;

+ (void)lockToLandscapeRight;

+ (void)unlockAllOrientations;

@end


