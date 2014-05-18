//
//  UIBarButtonItem+BarButtons.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

@interface UIBarButtonItem (BarButtons)

+ (UIBarButtonItem *)addButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)composeButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)doneButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)cancelButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)editButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)settingsButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)helpButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)infoButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)refreshButtonWithTarget:(id)target action:(SEL)action;

+ (UIBarButtonItem *)spinnerButton;

+ (UIBarButtonItem *)backButton;

@end
