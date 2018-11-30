//
//  ZKHeader.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#ifndef ZKHeader_h
#define ZKHeader_h

#define fixedScreenW ([[UIScreen mainScreen] respondsToSelector:@selector(fixedCoordinateSpace)] ? [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.width : [UIScreen mainScreen].bounds.size.width)

#define fixedScreenH ([[UIScreen mainScreen] respondsToSelector:@selector(fixedCoordinateSpace)] ? [UIScreen mainScreen].fixedCoordinateSpace.bounds.size.height : [UIScreen mainScreen].bounds.size.height)

#define kScalePhone6Value(x)  (ceilf(x) * (fixedScreenW / 375))


// 判断是否为iPhone X 系列
#define kIS_PhoneXAll \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define kNavBarHeight 44
#define kNavAndStatusBarHeight (kIS_PhoneXAll ? 88.0 : 64.0)

//状态栏高度
#define kStatusHeight (kIS_PhoneXAll ? 44 : 20)
//底部安全区域的高度  适配iPhone X
#define kSafeAreaInsetsBottom ((kIS_PhoneXAll) ? (34) : (0))



#endif /* ZKHeader_h */
