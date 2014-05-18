//
//  UIAlertView+AlertViews.h
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIAlertView (AlertViews)

+ (UIAlertView *)addNewSectionWithDelegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *)editSectionWithDelegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *)sendFeedbackToAddress:(NSString *)address delegate:(id<UIAlertViewDelegate>)delegate;

+ (UIAlertView *)pinsDidntMatchErrorWithDelegate:(id<UIAlertViewDelegate>)delegate;

@end
