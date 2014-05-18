//
//  CheckList.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Group;

@interface CheckList : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *items;
@end

@interface CheckList (CoreDataGeneratedAccessors)

- (void)addItemsObject:(NSManagedObject *)value;
- (void)removeItemsObject:(NSManagedObject *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
