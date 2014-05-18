//
//  UIColor+ThemeColor.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIColor+ThemeColor.h"

@implementation UIColor (ThemeColor)

+ (UIColor *)themeColor
{
    return [UIColor colorWithRed:(197.0/255.0) green:(0.0/255.0) blue:(65.0/255.0) alpha:1.0]; // #C50041
}

+ (UIColor *)pinButtonNormal
{
    return [UIColor colorWithRed:(204.0/255.0) green:(204.0/255.0) blue:(204.0/255.0) alpha:1.0];
}

+ (UIColor *)pinButtonPressed
{
    return [UIColor colorWithRed:(170.0/255.0) green:(170.0/255.0) blue:(170.0/255.0) alpha:1.0];
}

#pragma mark - Gray

+ (UIColor *)gray1
{
    return [UIColor colorWithRed:(239.0/255.0) green:(238.0/255.0) blue:(244.0/255.0) alpha:1.0];
}

+ (UIColor *)gray2
{
    return [UIColor colorWithRed:(219.0/255.0) green:(218.0/255.0) blue:(224.0/255.0) alpha:1.0];
}

+ (UIColor *)gray3
{
    return [UIColor colorWithRed:(199.0/255.0) green:(198.0/255.0) blue:(204.0/255.0) alpha:1.0];
}

@end
