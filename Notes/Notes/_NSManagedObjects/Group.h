//
//  Group.h
//
//  Created by Scott Lucien on 2/15/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;
@import CoreData;

@class CheckList, CheckListItem, Note, Photo, Reminder, VoiceMemo;

@interface Group : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSNumber * row;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isChecklist;
@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *checklists;
@property (nonatomic, retain) NSSet *checklistitems;
@property (nonatomic, retain) NSSet *reminders;
@property (nonatomic, retain) NSSet *voicememos;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addChecklistsObject:(CheckList *)value;
- (void)removeChecklistsObject:(CheckList *)value;
- (void)addChecklists:(NSSet *)values;
- (void)removeChecklists:(NSSet *)values;

- (void)addChecklistitemsObject:(CheckListItem *)value;
- (void)removeChecklistitemsObject:(CheckListItem *)value;
- (void)addChecklistitems:(NSSet *)values;
- (void)removeChecklistitems:(NSSet *)values;

- (void)addRemindersObject:(Reminder *)value;
- (void)removeRemindersObject:(Reminder *)value;
- (void)addReminders:(NSSet *)values;
- (void)removeReminders:(NSSet *)values;

- (void)addVoicememosObject:(VoiceMemo *)value;
- (void)removeVoicememosObject:(VoiceMemo *)value;
- (void)addVoicememos:(NSSet *)values;
- (void)removeVoicememos:(NSSet *)values;

@end
