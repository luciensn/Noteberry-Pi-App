//
//  BlockAnimationDelegate.h
//
//  Created by Scott Lucien on 8/19/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;

@interface BlockAnimationDelegate : NSObject

// Properties
@property (nonatomic, copy) void (^completion)(BOOL finished);
@property (nonatomic, assign) BOOL ignoreInteractionEvents;

// Methods
- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished;

@end
