//
//  UIBarButtonItem+BarButtons.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "UIBarButtonItem+BarButtons.h"
#import "UIColor+ThemeColor.h"

@implementation UIBarButtonItem (BarButtons)

+ (UIBarButtonItem *)addButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:target action:action];
}

+ (UIBarButtonItem *)composeButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:target action:action];
}

+ (UIBarButtonItem *)doneButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:target action:action];
}

+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:target action:action];
}

+ (UIBarButtonItem *)editButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:target action:action];
}

+ (UIBarButtonItem *)settingsButtonWithTarget:(id)target action:(SEL)action
{
    UIImage *image = [[UIImage imageNamed:@"more-icon-small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    return [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleBordered target:target action:action];
}

+ (UIBarButtonItem *)helpButtonWithTarget:(id)target action:(SEL)action
{
    NSString *help = NSLocalizedString(@"Help", nil);
    return [[UIBarButtonItem alloc] initWithTitle:help style:UIBarButtonItemStyleBordered target:target action:action];
}

+ (UIBarButtonItem *)infoButtonWithTarget:(id)target action:(SEL)action
{
    UIButton *helpButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    [helpButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
    return barButton;
}

+ (UIBarButtonItem *)refreshButtonWithTarget:(id)target action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:target action:action];
}

+ (UIBarButtonItem *)spinnerButton
{
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [spinner startAnimating];
    return [[UIBarButtonItem alloc] initWithCustomView:spinner];
}

+ (UIBarButtonItem *)backButton
{
    NSString *back = NSLocalizedString(@"Back", nil);
    return [[UIBarButtonItem alloc] initWithTitle:back style:UIBarButtonItemStyleBordered target:nil action:nil];
}

@end
