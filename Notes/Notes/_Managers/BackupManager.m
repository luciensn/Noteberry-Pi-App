//
//  BackupManager.m
//
//  Created by Scott Lucien on 2/26/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "BackupManager.h"
#import "AppDelegate.h"
#import "CoreDataManager.h"
#import "Group.h"

static NSString *const DESTINATION_PATH = @"DESTINATION_PATH";
static NSString *const LAST_BACKUP = @"USER_DEFAULTS_LAST_BACKUP";

NSString *const BackupDidCompleteNotification = @"BackupDidCompleteNotification";

@implementation BackupManager

+ (BackupManager *)sharedManager
{
    static BackupManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BackupManager alloc] init];
    });
    return sharedManager;
}

+ (NSString *)getDestination
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSString *)[defaults objectForKey:DESTINATION_PATH];
}

+ (void)saveDestination:(NSString *)destination
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:destination forKey:DESTINATION_PATH];
    [defaults synchronize];
}

+ (NSDate *)getLastBackupDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSDate *)[defaults objectForKey:LAST_BACKUP];
}

+ (void)saveLastBackupDate:(NSDate *)lastBackupDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:lastBackupDate forKey:LAST_BACKUP];
    [defaults synchronize];
}

#pragma mark - Instance Methods

- (void)sendBackupToDestination:(NSString *)destination completion:(BackupCompletionBlock)completion
{
    if (_requesting) {
        return;
    }
    [self setRequesting:YES];
    [self setCompletion:completion];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // dispatch to a background thread
    dispatch_queue_t backupQ = dispatch_queue_create("backupQueue", NULL);
    dispatch_async(backupQ, ^{
        
        // create the request
        NSURL *url = [NSURL URLWithString:destination];
        NSTimeInterval timeout = 6.0;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLCacheStorageNotAllowed];
        [request setTimeoutInterval:timeout];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        // add the message to the request body
        NSDictionary *jsonDict = [[CoreDataManager sharedManager] getJSONDictionary];
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            // TODO: json error
        }
        
        [request setHTTPBody:data];
        
        // send the request
        NSURLSession *session = [NSURLSession sharedSession];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if (error) {
                NSLog(@"%@", error);
            }
            
            // update UI on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self finishWithSuccess:!error];
            });
            
        }] resume];
    });
}

#pragma mark - Private Methods

- (void)finishWithSuccess:(BOOL)success {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setRequesting:NO];
    
    // save the backup time if successful
    if (success) {
        [BackupManager saveLastBackupDate:[NSDate date]];
        [[NSNotificationCenter defaultCenter] postNotificationName:BackupDidCompleteNotification object:nil];
    } else {
        [self showErrorAlertMessageWithTitle:@"Error!" message:@"Backup failed."];
    }
    
    // run the completion block
    if (_completion) {
        _completion(success);
    }
}

- (void)showErrorAlertMessageWithTitle:(NSString *)title message:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:title message:msg delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


/*
{
	"categories":[
                  { "displayName" : "Notes",
                    "children" : [
                            { "date" : "10/12/2014", "text" : "This is the note text." },
                            { "date" : "10/12/2014", "text" : "This is the note text."}
                        ]
                  },
                  
                  { "displayName" : "Ideas",
                    "children" : [
                            { "date" : "10/12/2014", "text" : "This is the note text." },
                            { "date" : "10/12/2014", "text" : "This is the note text."}
                        ]
                  }
                  
        ]
}
*/

@end
