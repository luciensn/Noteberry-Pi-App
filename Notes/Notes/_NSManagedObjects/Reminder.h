//
//  Reminder.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Group;

@interface Reminder : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * reminderDate;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) Group *group;

@end
