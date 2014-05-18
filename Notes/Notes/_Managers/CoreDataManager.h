//
//  CoreDataManager.h
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;

#import "Group.h"
#import "Note.h"

@interface CoreDataManager : NSObject

+ (CoreDataManager *)sharedManager;
- (void)initWithFreshInstall:(BOOL)freshInstall;

// Properties
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Properties - Data
@property (strong, nonatomic) NSMutableArray *groups;

// Methods - Manager
- (void)saveContext;
- (BOOL)hasChanges;

// Methods - Groups
- (void)fetchGroupsWithCompletion:(void(^)(void))completion;
- (NSInteger)numberOfGroups;
- (Group *)groupForRow:(NSInteger)row;
- (void)addNewGroupWithName:(NSString *)groupName completion:(void(^)(void))completion;
- (void)deleteGroupAtRow:(NSInteger)row completion:(void(^)(void))completion;
- (void)moveGroupAtRow:(NSInteger)from toRow:(NSInteger)to;

// Methods - Notes
- (Note *)newNoteInGroup:(Group *)group;
- (void)deleteNote:(Note *)note;

// Methods - Back Up Data
- (NSDictionary *)getJSONDictionary;

@end
