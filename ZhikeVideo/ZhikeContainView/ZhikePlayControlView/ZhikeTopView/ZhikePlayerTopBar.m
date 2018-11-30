
//
//  ZhikePlayerTopBar.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/12.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayerTopBar.h"
#import <Masonry/Masonry.h>
#import "ZKHeader.h"

@interface ZhikePlayerTopBar ()

@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *containView;
/** 视频title */
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ZhikePlayerTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isHidden = NO;
        [self addSubview:self.bgImageView];
        [self addSubview:self.containView];
        [self.containView addSubview:self.backBtn];
        [self.containView addSubview:self.titleLabel];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        // 底部控件的父视图
        [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.and.right.mas_equalTo(0);
            make.height.mas_equalTo(kScalePhone6Value(40));
        }];
        
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kScalePhone6Value(16), kScalePhone6Value(16)));
            make.left.mas_equalTo(10);
            make.top.mas_equalTo(16);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.backBtn.mas_right).offset(kScalePhone6Value(10));
            make.centerY.equalTo(self.backBtn.mas_centerY);
            make.right.equalTo(self).offset(kScalePhone6Value(-10));
            make.height.mas_equalTo(kScalePhone6Value(20));
        }];
        
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

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zkicon_top_shadow"]];
    }
    
    return _bgImageView;
}


- (LargeButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[LargeButton alloc] init];
        _backBtn.dx = -20;
        [_backBtn setImage:[UIImage imageNamed:@"zkicon_back"] forState:UIControlStateNormal];
    }
    
    return _backBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    
    return _titleLabel;
}



#pragma mark - Set
- (void)setVideoTitle:(NSString *)videoTitle {
    _videoTitle = videoTitle;
    self.titleLabel.text = _videoTitle;
}



#pragma mark - Private Method
- (void)isHiddenControl:(BOOL)isHidden animateComplete:(void (^ __nullable)(BOOL finished))completion {
    if (_isHidden == isHidden) {
        return;
    }
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



#pragma mark - updateViewConstraints
- (void)updateConstraints {
    if (_isHidden) {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(-kScalePhone6Value(40));
        }];
        
    } else {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
        }];
    }
    
    [super updateConstraints];
}


@end
