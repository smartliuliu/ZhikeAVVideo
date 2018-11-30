//
//  ZhikePlayerControlBar.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayerBottomBar.h"

@interface ZhikePlayerBottomBar ()

@property (nonatomic, assign) BOOL isHidden;

@property (nonatomic, strong) UIImageView *bgImageView;
/** 全屏按钮 */
@property (nonatomic, strong) LargeButton *fullScreenBtn;
/** 播放或暂停按钮 */
@property (nonatomic, strong) LargeButton *playSwitchBtn;
/** 倍速按钮 */
@property (nonatomic, strong) LargeButton *rateBtn;
/** 倍速按钮 */
@property (nonatomic, strong) LargeButton *smoothBtn;

@end

@implementation ZhikePlayerBottomBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isHidden = YES;
        [self addSubview:self.bgImageView];
        [self addSubview:self.containView];
        [self.containView addSubview:self.playSwitchBtn];
        [self.containView addSubview:self.currentTimeLabel];
        [self.containView addSubview:self.sliderView];
        [self.containView addSubview:self.totalTimeLabel];
        [self.containView addSubview:self.rateBtn];
        [self.containView addSubview:self.smoothBtn];
        [self.containView addSubview:self.fullScreenBtn];
        
        [self setBottomFrame];
    }
    return self;
}


#pragma mark - Get
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] init];
    }
    
    return _containView;
}

- (LargeButton *)playSwitchBtn {
    if (!_playSwitchBtn) {
        _playSwitchBtn = [LargeButton buttonWithType:UIButtonTypeCustom];
        _playSwitchBtn.dx = -10;
        [_playSwitchBtn setImage:[UIImage imageNamed:@"zkicon_play"] forState:UIControlStateNormal];
        [_playSwitchBtn setImage:[UIImage imageNamed:@"zkicon_pause"] forState:UIControlStateSelected];
        [_playSwitchBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playSwitchBtn;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        _currentTimeLabel.text = @"--:--:--";
    }
    return _currentTimeLabel;
}

- (ZKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[ZKSliderView alloc] init];
        _sliderView.bufferTrackTintColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _sliderView.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _sliderView.minimumTrackTintColor = [UIColor greenColor];
        [_sliderView setThumbImage:[UIImage imageNamed:@"zkicon_slider"] forState:UIControlStateNormal];
        _sliderView.sliderHeight = kScalePhone6Value(2);
    }
    return _sliderView;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:13.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        _totalTimeLabel.text = @"--:--:--";
    }
    return _totalTimeLabel;
}

- (LargeButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [LargeButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.dx = -10;
        [_fullScreenBtn setImage:[UIImage imageNamed:@"zkicon_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}

- (LargeButton *)rateBtn {
    if (!_rateBtn) {
        _rateBtn = [LargeButton buttonWithType:UIButtonTypeCustom];
        [_rateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_rateBtn addTarget:self action:@selector(rateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateBtn;
}

- (LargeButton *)smoothBtn {
    if (!_smoothBtn) {
        _smoothBtn = [LargeButton buttonWithType:UIButtonTypeCustom];
        [_smoothBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _smoothBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_smoothBtn addTarget:self action:@selector(smoothBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _smoothBtn;
}

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zkicon_bottom_shadow"]];
        _bgImageView.hidden = YES;
    }
    
    return _bgImageView;
}


#pragma mark Get Method
/** 播放暂停点击 */
- (void)playClick:(UIButton *)btn {
    BottomClickType type = !self.playSwitchBtn.isSelected ? BOTTOM_PLAY : BOTTOM_PAUSE;
    if ([self.delegate respondsToSelector:@selector(bottomClickBtn:type:)]) {
        [self.delegate bottomClickBtn:btn type:type];
    }
}

/** 全屏点击 */
- (void)fullBtnClick:(UIButton *)btn {
    self.isFullScreen = !self.isFullScreen;
    BottomClickType type = self.isFullScreen ? BOTTOM_LANDSCAPE : BOTTOM_PORTRAIT;
    if ([self.delegate respondsToSelector:@selector(bottomClickBtn:type:)]) {
        [self.delegate bottomClickBtn:btn type:type];
    }
}

/** 清晰度 */
- (void)smoothBtnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(bottomClickBtn:type:)]) {
        [self.delegate bottomClickBtn:btn type:BOTTOM_SMOOTH];
    }
}

/** 速率 */
- (void)rateBtnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(bottomClickBtn:type:)]) {
        [self.delegate bottomClickBtn:btn type:BOTTOM_RATE];
    }
}


#pragma mark - Set
- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    self.playSwitchBtn.selected = isPlaying;
}

- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    [self changeFullScreenControl];
    [self updateConstraints];
}


#pragma mark - Public Method
- (void)isHiddenControl:(BOOL)isHidden animateComplete:(void (^ __nullable)(BOOL finished))completion {
    _isHidden = isHidden;
    if(!_isHidden) {
        self.hidden = _isHidden;
    }
    // 通知需要更新约束，但是不立即执行
    [self setNeedsUpdateConstraints];
    // 立即更新约束，以执行动态变换
    [self updateConstraintsIfNeeded];
    // 执行动画效果, 设置动画时间
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
        self.bgImageView.hidden = isHidden;
    } completion:^(BOOL finished) {
        self.hidden = isHidden;
        completion(finished);
    }];
}

/** 改变清晰度和倍速的bottom名称 */
- (void)changeLandName {
    [_smoothBtn setTitle:[self.smoothArray[self.smoothIndex] objectForKey:@"name"] forState:UIControlStateNormal];
    [_rateBtn setTitle:[NSString stringWithFormat:@"%@X", self.ratesArray[self.rateIndex]] forState:UIControlStateNormal];
}




#pragma mark - Private Method
- (void)changeFullScreenControl {
    if(!self.isFullScreen) {
        // 全屏按钮
        [self.fullScreenBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScalePhone6Value(20), kScalePhone6Value(20)));
            make.right.mas_equalTo(kScalePhone6Value(-10));
            make.centerY.equalTo(self.containView.mas_centerY);
        }];
        
    } else {
        [self.fullScreenBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeZero);
            make.right.mas_equalTo(0);
        }];
    }
    
    BOOL isSmoothHidden = !self.smoothArray.count ? YES : !self.isFullScreen;
    if (!isSmoothHidden) {
        [_smoothBtn setTitle:[self.smoothArray[self.smoothIndex] objectForKey:@"name"] forState:UIControlStateNormal];
        [self.smoothBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containView.mas_centerY);
            make.right.equalTo(self.fullScreenBtn.mas_left).offset(kScalePhone6Value(-10));
            make.width.mas_equalTo(kScalePhone6Value(50));
            make.height.equalTo(self.playSwitchBtn.mas_height);
        }];
        
    } else {
        [self.smoothBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.right.equalTo(self.fullScreenBtn.mas_left);
            make.centerY.equalTo(self.containView.mas_centerY);
        }];
    }
    
    BOOL isRateHidden = !self.ratesArray.count ? YES : !self.isFullScreen;
    if (!isRateHidden) {
        [_rateBtn setTitle:[NSString stringWithFormat:@"%@X", self.ratesArray[self.rateIndex]] forState:UIControlStateNormal];
        [self.rateBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containView.mas_centerY);
            make.right.equalTo(self.smoothBtn.mas_left).offset(kScalePhone6Value(-10));
            make.width.mas_equalTo(kScalePhone6Value(50));
            make.height.equalTo(self.playSwitchBtn.mas_height);
        }];
    } else {
        [self.rateBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
            make.right.equalTo(self.smoothBtn.mas_left);
            make.centerY.equalTo(self.containView.mas_centerY);
        }];
    }
}

- (void)setBottomFrame {
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    // 底部控件的父视图
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kScalePhone6Value(35));
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(kScalePhone6Value(35));
    }];
    
    // 开始按钮
    [self.playSwitchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScalePhone6Value(20), kScalePhone6Value(20)));
        make.left.mas_equalTo(kScalePhone6Value(10));
        make.centerY.equalTo(self.containView.mas_centerY);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containView.mas_centerY);
        make.left.equalTo(self.playSwitchBtn.mas_right).offset(kScalePhone6Value(15));
        make.width.mas_equalTo(kScalePhone6Value(60));
        make.height.equalTo(self.playSwitchBtn.mas_height);
    }];
    
    // 全屏按钮
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScalePhone6Value(20), kScalePhone6Value(20)));
        make.right.mas_equalTo(kScalePhone6Value(-10));
        make.centerY.equalTo(self.containView.mas_centerY);
    }];
    
    [self.smoothBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.right.equalTo(self.fullScreenBtn.mas_left);
        make.centerY.equalTo(self.containView.mas_centerY);
    }];

    [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(0);
        make.right.equalTo(self.smoothBtn.mas_left);
        make.centerY.equalTo(self.containView.mas_centerY);
    }];

    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containView.mas_centerY);
        make.right.equalTo(self.rateBtn.mas_left).offset(kScalePhone6Value(-10));
        make.width.mas_equalTo(kScalePhone6Value(60));
        make.height.equalTo(self.playSwitchBtn.mas_height);
    }];
    
    // 进度条
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.containView.mas_centerY);
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(kScalePhone6Value(10));
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(kScalePhone6Value(-10));
        make.height.equalTo(self.containView.mas_height);
    }];
    
}



#pragma mark - updateViewConstraints frame
- (void)updateConstraints {
    CGFloat bottom = 0;
    if (self.isFullScreen) {
        bottom = kScalePhone6Value(20);
    }
    if (_isHidden) {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(kScalePhone6Value(35) + bottom);
        }];
        
    } else {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-bottom);
        }];
    }
    
    [super updateConstraints];
}

@end

