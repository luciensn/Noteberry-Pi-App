//
//  UIAlertView+AlertViews.m
//
//  Created by Scott Lucien on 1/22/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "UIAlertView+AlertViews.h"

@implementation UIAlertView (AlertViews)

+ (UIAlertView *)addNewSectionWithDelegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"New Category", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *ok = NSLocalizedString(@"Add", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                         message:nil
                                                        delegate:delegate
                                               cancelButtonTitle:cancel
                                               otherButtonTitles:ok, nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    return alertView;
}

+ (UIAlertView *)editSectionWithDelegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"Rename Category", nil);
    NSString *cancel = NSLocalizedString(@"Cancel", nil);
    NSString *ok = NSLocalizedString(@"Save", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:delegate
                                              cancelButtonTitle:cancel
                                              otherButtonTitles:ok, nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [[alertView textFieldAtIndex:0] setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    return alertView;
}

+ (UIAlertView *)sendFeedbackToAddress:(NSString *)address delegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"Feedback", nil);
    NSString *message = NSLocalizedString(@"Send feedback to", nil);
    NSString *combined = [NSString stringWithFormat:@"%@\n%@", message, address];
    NSString *ok = NSLocalizedString(@"OK", nil);
    return [[UIAlertView alloc] initWithTitle:title
                                      message:combined
                                     delegate:delegate
                            cancelButtonTitle:ok
                            otherButtonTitles:nil];
}

+ (UIAlertView *)pinsDidntMatchErrorWithDelegate:(id<UIAlertViewDelegate>)delegate
{
    NSString *title = NSLocalizedString(@"Try Again", nil);
    NSString *message = NSLocalizedString(@"Passcodes did not match.", nil);
    NSString *ok = NSLocalizedString(@"OK", nil);
    return [[UIAlertView alloc] initWithTitle:title
                                      message:message
                                     delegate:delegate
                            cancelButtonTitle:ok
                            otherButtonTitles:nil];
}

@end
