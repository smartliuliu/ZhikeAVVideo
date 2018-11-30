//
//  UIImage+BundleImage.m
//  ZhikeVideo-ZhikeVideo
//
//  Created by liu on 2018/11/30.
//

#import "UIImage+BundleImage.h"

@implementation UIImage (BundleImage)

+ (UIImage *)getImage:(NSString *)imgName {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"ZhikeVideo" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        if (@available(iOS 8.0, *)) {
            return [UIImage imageNamed:imgName inBundle:bundle compatibleWithTraitCollection:nil];
        } else {
            return [UIImage imageWithContentsOfFile:[bundle pathForResource:imgName ofType:@"png"]];
        }
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:imgName ofType:@"png"]];
    }
}

@end
