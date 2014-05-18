//
//  BackupManager.h
//
//  Created by Scott Lucien on 2/26/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;

@interface BackupManager : NSObject

extern NSString *const BackupDidCompleteNotification;

typedef void (^BackupCompletionBlock)(BOOL success);

// Class Methods
+ (BackupManager *)sharedManager;

// User Defaults
+ (NSString *)getDestination;
+ (void)saveDestination:(NSString *)destination;
+ (NSDate *)getLastBackupDate;
+ (void)saveLastBackupDate:(NSDate *)lastBackupDate;

// Properties
@property (nonatomic, copy) BackupCompletionBlock completion;
@property (nonatomic) BOOL requesting;

// Methods
- (void)sendBackupToDestination:(NSString *)destination completion:(BackupCompletionBlock)completion;

@end
