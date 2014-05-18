//
//  UIImage+Options.h
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIImage (Options)

+ (UIImage *)imageNamed:(NSString *)imageName withMaskImageNamed:(NSString *)maskImageName;

+ (UIImage *)image:(UIImage *)image maskedByImage:(UIImage *)maskImage;

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
