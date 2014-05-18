//
//  BlockAnimationDelegate.m
//
//  Created by Scott Lucien on 8/19/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "BlockAnimationDelegate.h"

@implementation BlockAnimationDelegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished
{
    if (_completion) {
        _completion([finished boolValue]);
    }
    
    if (_ignoreInteractionEvents) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
