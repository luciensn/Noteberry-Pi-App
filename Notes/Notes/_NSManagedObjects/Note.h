//
//  Note.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Group, Photo;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
