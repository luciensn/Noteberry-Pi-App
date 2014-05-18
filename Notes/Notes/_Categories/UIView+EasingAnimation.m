//
//  UIView+EasingAnimation.m
//
//  Created by Scott Lucien on 8/15/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIView+EasingAnimation.h"
#import "BlockAnimationDelegate.h"

@implementation UIView (EasingAnimation)

+ (void)animateWithEasing:(void(^)(void))animations
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:7];
    animations();
    [UIView commitAnimations];
}

+ (void)animateWithEasing:(void(^)(void))animations completion:(void (^)(BOOL finished))completion
{
    BOOL ignoreInteractionEvents = YES;
    if (ignoreInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    BlockAnimationDelegate *delegate = [[BlockAnimationDelegate alloc] init];
    delegate.completion = completion;
    delegate.ignoreInteractionEvents = ignoreInteractionEvents;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    animations();
    [UIView commitAnimations];
}

+ (void)animateFromCurrentStateWithEasing:(void(^)(void))animations completion:(void (^)(BOOL finished))completion
{
    BOOL ignoreInteractionEvents = YES;
    if (ignoreInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    BlockAnimationDelegate *delegate = [[BlockAnimationDelegate alloc] init];
    delegate.completion = completion;
    delegate.ignoreInteractionEvents = ignoreInteractionEvents;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    animations();
    [UIView commitAnimations];
}

+ (void)animateWithEasingDuration:(NSTimeInterval)duration animations:(void(^)(void))animations completion:(void (^)(BOOL finished))completion
{
    BOOL ignoreInteractionEvents = YES;
    if (ignoreInteractionEvents) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    BlockAnimationDelegate *delegate = [[BlockAnimationDelegate alloc] init];
    delegate.completion = completion;
    delegate.ignoreInteractionEvents = ignoreInteractionEvents;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationDelegate:delegate];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
    animations();
    [UIView commitAnimations];
}

@end
