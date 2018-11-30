
//
//  LargeButton.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/22.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "LargeButton.h"

@implementation LargeButton

- (CGFloat)dy {
    if (!_dy) {
        _dy = -10;
    }
    
    return _dy;
}

// 重写此方法将按钮的点击范围扩大
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    // 扩大点击区域
    bounds = CGRectInset(bounds, self.dx, self.dy);
    // 若点击的点在新的bounds里面。就返回yes
    return CGRectContainsPoint(bounds, point);
}

@end
