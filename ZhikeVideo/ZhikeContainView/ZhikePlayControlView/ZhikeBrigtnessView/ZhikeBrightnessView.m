//
//  LMBrightnessView.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/16.
//  Copyright © 2018年 liu. All rights reserved.

#import "ZhikeBrightnessView.h"
#import "ZKHeader.h"
#import "UIImage+BundleImage.h"

@interface ZhikeBrightnessView ()

@property (nonatomic, strong) UIImageView *signImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) NSMutableArray *tipArray;

@end

@implementation ZhikeBrightnessView

static ZhikeBrightnessView *instance;

+ (instancetype)sharedBrightnessView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZhikeBrightnessView alloc] init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(fixedScreenW * 0.5, fixedScreenH * 0.5, 155, 155);
        self.layer.cornerRadius  = 10;
        self.layer.masksToBounds = YES;
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        [self addSubview:self.signImageView];
        [self addSubview:self.titleLabel];
        
        [self addSubview:self.containView];
        [self addSubview:self.containView];
        
        [self addObserver];
        
        self.alpha = 0.0;
    }
    return self;
}



#pragma mark - Ge
-(UIImageView *)signImageView {
    if (!_signImageView) {
        _signImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 79, 76)];
        _signImageView.image = [UIImage getImage:@"zkicon_brightness"];
    }
    
    return _signImageView;
}


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"亮度";
    }
    
    return _titleLabel;
}

- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
        _containView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        self.tipArray = [NSMutableArray arrayWithCapacity:16];
        CGFloat tipW = (_containView.bounds.size.width - 17) / 16;
        CGFloat tipH = 5;
        CGFloat tipY = 1;
        
        for (int i = 0; i < 16; i++) {
            CGFloat tipX = i * (tipW + 1) + 1;
            UIImageView *image = [[UIImageView alloc] init];
            image.backgroundColor = [UIColor whiteColor];
            image.frame = CGRectMake(tipX, tipY, tipW, tipH);
            [_containView addSubview:image];
            [self.tipArray addObject:image];
        }
        
        [self updateLongView:[UIScreen mainScreen].brightness];
    }
    
    return _containView;
}


#pragma makr - 通知 KVO

- (void)addObserver {
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat sound = [change[@"new"] floatValue];
    [self appearBrightnessView];
    [self updateLongView:sound];
}

#pragma mark - Methond

- (void)appearBrightnessView {
    if (self.alpha == 0.0) {
        self.alpha = 1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self disAppearBrightnessView];
        });
    }
}

- (void)disAppearBrightnessView {
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        }];
    }
}

#pragma mark - Update View

- (void)updateLongView:(CGFloat)brightness {
    CGFloat stage = 1 / 15.0;
    NSInteger level = brightness / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.signImageView.center = CGPointMake(155 * 0.5, 155 * 0.5);
}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [instance removeFromSuperview];
}

@end
