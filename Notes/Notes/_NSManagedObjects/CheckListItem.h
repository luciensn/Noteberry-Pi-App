//
//  CheckListItem.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class CheckList, Group;

@interface CheckListItem : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) CheckList *checklist;

@end
