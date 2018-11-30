//
//  ZhikePlayControlView.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/16.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayControlView.h"

@interface ZhikePlayControlView() {
    dispatch_block_t _hiddenBlock;
}

@end

@implementation ZhikePlayControlView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.topBarView];
        [self addSubview:self.centerPlayBtn];
        [self addSubview:self.bottomBarView];
        
        [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.mas_equalTo(0);
            make.height.mas_equalTo(kScalePhone6Value(80));
        }];
        
        [self.bottomBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(0);
            make.height.mas_equalTo(kScalePhone6Value(80));
        }];
        
        [self.centerPlayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(kScalePhone6Value(44), kScalePhone6Value(44)));
        }];
    }
    return self;
}


#pragma mark - Get
- (ZhikePlayerBottomBar *)bottomBarView {
    if (!_bottomBarView) {
        _bottomBarView = [[ZhikePlayerBottomBar alloc] init];
        _bottomBarView.hidden = YES;
    }
    
    return _bottomBarView;
}

- (ZhikePlayerTopBar *)topBarView {
    if (!_topBarView) {
        _topBarView = [[ZhikePlayerTopBar alloc] init];
    }
    
    return _topBarView;
}

- (UIButton *)centerPlayBtn {
    if (!_centerPlayBtn) {
        _centerPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_centerPlayBtn setImage:[UIImage imageNamed:@"zkicon_center_play"] forState:UIControlStateNormal];
        [_centerPlayBtn setImage:[UIImage imageNamed:@"zkicon_center_pause"] forState:UIControlStateSelected];
    }
    
    return _centerPlayBtn;
}



#pragma mark - Set
- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    
    self.bottomBarView.isPlaying = isPlaying;
    // 播放时候中心按钮隐藏
    self.centerPlayBtn.hidden = isPlaying;
}



#pragma mark - Public Method
- (void)changeIsShowBottomView:(BOOL)isShow {
    self.isShowControlView = isShow;
    
    if (!isShow) {
        [self cancelAutoFadeOutControlView];
    }
    [self.topBarView isHiddenControl:!isShow animateComplete:^(BOOL finished) {
        
    }];
    [self.bottomBarView isHiddenControl:!isShow animateComplete:^(BOOL finished) {
        if (isShow) {
             [self autoFadeOutControlView];
        }
    }];
}

// 开启自动隐藏控制条
- (void)autoFadeOutControlView {
    [self cancelAutoFadeOutControlView];
    __weak typeof(self) weakSelf = self;
    _hiddenBlock = dispatch_block_create(0, ^{
        [weakSelf changeIsShowBottomView:NO];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5f * NSEC_PER_SEC)), dispatch_get_main_queue(),_hiddenBlock);
}

// 取消延时隐藏
- (void)cancelAutoFadeOutControlView {
    if (_hiddenBlock) {
        dispatch_block_cancel(_hiddenBlock);
        _hiddenBlock = nil;
    }
}

- (void)dealloc {
    [self cancelAutoFadeOutControlView];
}

@end
