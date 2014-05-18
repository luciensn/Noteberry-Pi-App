//
//  CoreDataManager.m
//
//  Created by Scott Lucien on 11/2/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "CoreDataManager.h"
#import "AppDelegate.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (CoreDataManager *)sharedManager
{
    static CoreDataManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CoreDataManager alloc] init];
    });
    return sharedManager;
}

#pragma mark -

- (void)initWithFreshInstall:(BOOL)freshInstall
{
    _managedObjectContext = [self managedObjectContext];
    if (freshInstall) {
        [self initialSetup];
    }
}

- (void)initialSetup
{
    // add a "Notes" category the first time users launch the app
    [self addNewGroupWithName:NSLocalizedString(@"Notes", nil) completion:nil];
}

#pragma mark - Core Data stack

- (void)saveContext
{
    // save the current index for each group
    [self updateGroupIndeces];
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error : -[CoreDataManager saveContext] : %@, %@", error, [error userInfo]);
            //abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notes" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    AppDelegate *delegate = [AppDelegate appDelegate];
    NSURL *storeURL = [[delegate applicationDocumentsDirectory] URLByAppendingPathComponent:@"Notes.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error : -[CoreDataManager persistentStoreCoordinator] : %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Groups

- (void)fetchGroupsWithCompletion:(void(^)(void))completion
{
    _groups = [self fetchGroupsIntoArray];
    
    // completion handler
    if (completion) {
        completion();
    }
}

- (NSMutableArray *)fetchGroupsIntoArray
{
    // fetch all group objects
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Group" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // sort groups by row
    NSSortDescriptor *sortByRow = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortByRow]];
    
    NSArray *groups = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    return [NSMutableArray arrayWithArray:groups];
}

- (NSInteger)numberOfGroups
{
    return [_groups count];
}

- (Group *)groupForRow:(NSInteger)row
{
    return (Group *)_groups[row];
}

- (void)addNewGroupWithName:(NSString *)groupName completion:(void(^)(void))completion
{
    // insert the new group into the managed object context
    Group *newGroup = (Group *)[NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:_managedObjectContext];
    [newGroup setDisplayName:groupName];
    
    // add the group to the end of the list
    NSInteger groupRow = [_groups count];
    [newGroup setRow:[NSNumber numberWithInteger:groupRow]];
    
    // insert the group into the array
    [_groups addObject:newGroup];
    
    // completion handler
    if (completion) {
        completion();
    }
}

- (void)deleteGroupAtRow:(NSInteger)row completion:(void(^)(void))completion
{
    Group *group = (Group *)_groups[row];
    [_groups removeObject:group];
    
    [_managedObjectContext deleteObject:group];
    
    // completion handler
    if (completion) {
        completion();
    }
}

- (void)deleteGroup:(Group *)group completion:(void(^)(void))completion
{
    if ([_groups containsObject:group]) {
        [_groups removeObject:group];
    }

    [_managedObjectContext deleteObject:group];

    // completion handler
    if (completion) {
        completion();
    }
}

- (void)moveGroupAtRow:(NSInteger)from toRow:(NSInteger)to
{
    Group *group = _groups[from];
    [_groups removeObject:group];
    [_groups insertObject:group atIndex:to];
}

- (void)updateGroupIndeces
{
    for (NSInteger i = 0; i < _groups.count; i++) {
        Group *group = _groups[i];
        [group setRow:[NSNumber numberWithInteger:i]];
    }
}

#pragma mark - Notes

- (Note *)newNoteInGroup:(Group *)group
{
    Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:_managedObjectContext];
    [group addNotesObject:newNote];
    [newNote setGroup:group];
    return newNote;
}

- (void)deleteNote:(Note *)note
{
    Group *group = note.group;
    [group removeNotesObject:note];
    [_managedObjectContext deleteObject:note];
    note = nil;
}

#pragma mark - Other

- (BOOL)hasChanges
{
    return [_managedObjectContext hasChanges];
}

#pragma mark - Back Up Data

- (NSDictionary *)getJSONDictionary
{
    NSArray *categories = [NSArray arrayWithArray:_groups];
    NSMutableArray *categoriesArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < categories.count; i++) {
        Group *group = (Group *)categories[i];
        
        // display name
        NSMutableDictionary *categoryDict = [[NSMutableDictionary alloc] init];
        [categoryDict setObject:group.displayName forKey:@"displayName"];
        
        // notes (children)
        NSMutableArray *notesArray = [[NSMutableArray alloc] init];
        NSSet *notes = group.notes;
        for (Note *note in notes) {
            NSMutableDictionary *noteDict = [[NSMutableDictionary alloc] init];
            NSString *dateString = [NSString stringWithFormat:@"%@", note.date];
            [noteDict setObject:dateString forKey:@"date"];
            [noteDict setObject:note.text forKey:@"text"];
            [notesArray addObject:noteDict];
        }
        [categoryDict setObject:notesArray forKey:@"children"];
        
        // add the dictionary to the array
        [categoriesArray addObject:categoryDict];
    }
    
    // return the dictionary that will be used to build the JSON data
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setObject:categoriesArray forKey:@"categories"];
    
    return jsonDict;
}

@end
