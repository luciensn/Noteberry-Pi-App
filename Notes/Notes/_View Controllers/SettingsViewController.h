//
//  SettingsViewController.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "BaseViewController.h"
#import "PINSetupDelayViewController.h"

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)settingsViewControllerDidDismiss:(SettingsViewController *)controller;
@end

@interface SettingsViewController : BaseViewController <PinSetupDelayViewControllerDelegate>

- (id)initWithSettingsDelegate:(id<SettingsViewControllerDelegate>)delegate;

// Properties
@property (weak, nonatomic) id<SettingsViewControllerDelegate> settingsDelegate;

@end
