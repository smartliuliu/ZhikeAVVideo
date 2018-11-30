//
//  ZhikePlayControlView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/16.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZhikePlayerTopBar.h"
#import "ZhikePlayerBottomBar.h"

@interface ZhikePlayControlView : UIView
/** 底部控制条 */
@property (nonatomic, strong) ZhikePlayerBottomBar *bottomBarView;
/** 顶部工具栏 */
@property (nonatomic, strong) ZhikePlayerTopBar *topBarView;
/** 中心播放/暂停按钮 */
@property (nonatomic, strong) UIButton *centerPlayBtn;

@property (nonatomic, assign) BOOL isPlaying;
/** 是否展示ControlBottom */
@property (nonatomic, assign) BOOL isShowControlView;


/** 是否显示控制条 */
- (void)changeIsShowBottomView:(BOOL)isShow;
/** 开启自动隐藏控制条 */
- (void)autoFadeOutControlView;
/** 取消延时隐藏控制条 */
- (void)cancelAutoFadeOutControlView;

@end

