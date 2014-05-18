//
//  AppDelegate.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import UIKit;

#import "CoreDataManager.h"
#import "NSDateFormatter+Formatter.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)appDelegate;

// Properties
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *splashScreen;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// Methods
- (NSURL *)applicationDocumentsDirectory;

@end
