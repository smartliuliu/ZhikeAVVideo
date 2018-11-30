//
//  ZhikeSRBaseView.m
//  ZhikeVideo
//
//  Created by liu on 2018/11/21.
//  Copyright © 2018年 liu. All rights reserved.
//

#import "ZhikePlayLandView.h"

@interface ZhikePlayLandView ()

@property (nonatomic, strong) UIView *containView;
@property (nonatomic, assign) BOOL isShow;

@end

@implementation ZhikePlayLandView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.containView];
        
        [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.mas_equalTo(0);
            make.width.mas_equalTo(kScalePhone6Value(20));
            make.right.equalTo(self).offset(kScalePhone6Value(200));
        }];
        
        UITapGestureRecognizer *ui=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ges)];
        self.userInteractionEnabled=YES;
        [self addGestureRecognizer:ui];
        
    }
    
    return self;
}



#pragma mark -  Get
- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] init];
        _containView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    
    return _containView;
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.containArray.count; i ++) {
            UIButton *view = [[UIButton alloc] init];
            view.tag = 100 + i;
            id name = self.containArray[i];
            if ([self.containArray[i] isKindOfClass:[NSDictionary class]]) {
                name = [self.containArray[i] objectForKey:@"name"];
            } else {
                name = [NSString stringWithFormat:@"%@X", name];
            }
            [view setTitle:name forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
            [view addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.containView addSubview:view];
            [_viewArray addObject:view];
        }
    }
    
    return _viewArray;
}


#pragma mark Get Method
- (void)btnClick:(UIButton *)btn {
    NSInteger index = btn.tag - 100;
    if (self.selectedIndex != index) {
        UIButton *lastBtn = [self.containView viewWithTag:self.selectedIndex + 100];
        lastBtn.selected = NO;
        btn.selected = YES;
        self.selectedIndex = index;
        if (self.clickBtnBlock) {
            self.clickBtnBlock(btn, index);
        }
    }
    
    // 隐藏
    [self ges];
}



#pragma mark - Set
- (void)setContainArray:(NSArray *)containArray {
    if (!_containArray) {
        _containArray = containArray;
        // 实现masonry垂直固定控件高度方法
        [self.viewArray mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:10 leadSpacing:30 tailSpacing:30];
        
        // 设置array的水平方向的约束
        [self.viewArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(kScalePhone6Value(200));
        }];
    }
}



#pragma mark - Public Method
/** 展示 */
- (void)showLandView:(BOOL)isShow {
    if (self.isShow == isShow) {
        return;
    }
    
    if(isShow) {
        UIButton *lastBtn = [self.containView viewWithTag:self.selectedIndex + 100];
        lastBtn.selected = YES;
    }
    
    [self isHiddenControl:!isShow animateComplete:^(BOOL finished) {}];
}



#pragma mark - Private Method
- (void)isHiddenControl:(BOOL)isHidden animateComplete:(void (^ __nullable)(BOOL finished))completion {
    self.isShow = !isHidden;
    self.hidden = NO;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = isHidden;
        completion(finished);
    }];
}

- (void)ges {
    [self isHiddenControl:YES animateComplete:^(BOOL finished) {}];
}



#pragma mark - updateViewConstraints frame
- (void)updateConstraints {
    if (_isShow) {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.mas_equalTo(0);
            make.width.mas_equalTo(kScalePhone6Value(200));
            make.right.equalTo(self);
        }];
    } else {
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.mas_equalTo(0);
            make.width.mas_equalTo(kScalePhone6Value(200));
            make.right.equalTo(self).offset(kScalePhone6Value(200));
        }];
    }
    
    [super updateConstraints];
}


@end


