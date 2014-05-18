//
//  Photo.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class Group, Note, VoiceMemo;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) Group *group;
@property (nonatomic, retain) VoiceMemo *voicememo;

@end
