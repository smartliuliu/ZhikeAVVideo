//
//  ZKNetworkSpeedMonitor.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/13.
//  Copyright © 2018年 liu. All rights reserved.
//
#import <Foundation/Foundation.h>

extern NSString *const ZKDownloadNetworkSpeedNotificationKey;
extern NSString *const ZKUploadNetworkSpeedNotificationKey;
extern NSString *const ZKNetworkSpeedNotificationKey;

@interface ZKNetworkSpeedMonitor : NSObject

@property (nonatomic, copy, readonly) NSString *downloadNetworkSpeed;
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;

- (void)startNetworkSpeedMonitor;
- (void)stopNetworkSpeedMonitor;

@end
