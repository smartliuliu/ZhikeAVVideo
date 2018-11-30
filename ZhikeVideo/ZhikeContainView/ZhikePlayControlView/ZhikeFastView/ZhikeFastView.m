//
//  ZhikeFastView.m
//  ZhikeAVVideo
//
//  Created by liu on 2018/11/26.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikeFastView.h"
#import <Masonry/Masonry.h>

@implementation ZhikeFastView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.fastTimeLabel];
        [self addSubview:self.fastProgressView];
    }
    return self;
}

#pragma mark - Get
- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel = [[UILabel alloc] init];
        _fastTimeLabel.textColor = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font = [UIFont boldSystemFontOfSize:16];
        _fastTimeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _fastTimeLabel;
}

- (ZKSliderView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView = [[ZKSliderView alloc] init];
        _fastProgressView.backgroundColor = [UIColor purpleColor];
        _fastProgressView.bufferTrackTintColor = [UIColor redColor];
        _fastProgressView.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        _fastProgressView.minimumTrackTintColor = [UIColor greenColor];
        _fastProgressView.sliderHeight = kScalePhone6Value(2);
        _fastProgressView.allowTapped = NO;
        _fastProgressView.isHideSliderBlock = YES;
        
    }
    return _fastProgressView;
}

- (void)layoutSubviews {
    [self.fastTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.with.right.mas_equalTo(0);
        make.top.mas_equalTo(self);
        make.height.mas_offset(kScalePhone6Value(18));
    }];
    
    [self.fastProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.with.right.mas_equalTo(0);
        make.top.mas_equalTo(self.fastTimeLabel.mas_bottom).offset(kScalePhone6Value(10));
        make.height.mas_equalTo(kScalePhone6Value(10));
    }];
}

- (void)setTimeText:(NSString *)timeText {
    _timeText = timeText;
    NSArray *arr = [_timeText componentsSeparatedByString:@"/"];
    if (arr.count < 2) {
        return;
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:timeText];
    [attr addAttribute:NSForegroundColorAttributeName
                      value:[UIColor greenColor]
                      range:[timeText rangeOfString:arr[0]]];
    self.fastTimeLabel.attributedText = attr;
}


@end
