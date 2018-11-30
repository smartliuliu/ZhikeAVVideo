//
//  ZhikePlayLandView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/21.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKHeader.h"
#import <Masonry/Masonry.h>

/** 倍速/清晰度 View */
@interface ZhikePlayLandView : UIView

@property (nonatomic, strong) NSArray *containArray;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray *viewArray;
/** 点击 btn Block */
typedef void(^clickView)(UIView *view, NSInteger index);
@property (nonatomic, copy) clickView clickBtnBlock;



/** 展示或者隐藏 */
- (void)showLandView:(BOOL)isShow;
@end

