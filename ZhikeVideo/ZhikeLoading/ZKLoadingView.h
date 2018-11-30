////
//  ZKLoadingView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/13.
//  Copyright © 2018年 liu. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZKLoadingType) {
    ZKLoadingTypeKeep,
    ZKLoadingTypeFadeOut,
};

@interface ZKLoadingView : UIView

/// default is ZKLoadingTypeKeep.
@property (nonatomic, assign) ZKLoadingType animType;

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// Sets the line width of the spinner's circle.
@property (nonatomic) CGFloat lineWidth;

/// Sets whether the view is hidden when not animating.
@property (nonatomic) BOOL hidesWhenStopped;

/// Property indicating the duration of the animation, default is 1.5s.
@property (nonatomic, readwrite) NSTimeInterval duration;

/// anima state
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end

