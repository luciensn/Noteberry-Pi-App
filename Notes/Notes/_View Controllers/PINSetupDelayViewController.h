//
//  PINSetupDelayViewController.h
//
//  Created by Scott Lucien on 11/23/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "BaseViewController.h"
#import "PinManager.h"

@class PINSetupDelayViewController;

@protocol PinSetupDelayViewControllerDelegate <NSObject>
- (void)pinSetupDelayViewControllerDidSelectDelay:(PinDelay)delay;
@end

@interface PINSetupDelayViewController : BaseViewController

- (id)initWithDelegate:(id<PinSetupDelayViewControllerDelegate>)setupDelayDelegate;

// Properties
@property (weak, nonatomic) id<PinSetupDelayViewControllerDelegate> setupDelayDelegate;

@end
