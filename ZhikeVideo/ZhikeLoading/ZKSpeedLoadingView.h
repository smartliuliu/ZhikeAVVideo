//
//  ZKSpeedLoadingView.h
//  ZhikeVideo
//
//  Created by liu on 2018/11/13.
//  Copyright © 2018年 liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKLoadingView.h"

@interface ZKSpeedLoadingView : UIView

@property (nonatomic, strong) ZKLoadingView *loadingView;

@property (nonatomic, strong) UILabel *speedTextLabel;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end
