//
//  PINViewController.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "BaseViewController.h"
#import "PINKeypadView.h"

typedef void (^PinCompletionBlock)(BOOL success);

@interface PINViewController : BaseViewController <PINKeypadDelegate>

- (id)initWithPinLockedModeWithCompletion:(PinCompletionBlock)completion;
- (id)initWithEnterPinModeWithCompletion:(PinCompletionBlock)completion;
- (id)initWithCreateNewPinModeWithCompletion:(PinCompletionBlock)completion;
- (id)initWithChangePinModeWithCompletion:(PinCompletionBlock)completion;

@end