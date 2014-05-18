//
//  UIView+EasingAnimation.h
//
//  Created by Scott Lucien on 8/15/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIView (EasingAnimation)

+ (void)animateWithEasing:(void(^)(void))animations;
+ (void)animateWithEasing:(void(^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateFromCurrentStateWithEasing:(void(^)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)animateWithEasingDuration:(NSTimeInterval)duration animations:(void(^)(void))animations completion:(void (^)(BOOL finished))completion;

@end
