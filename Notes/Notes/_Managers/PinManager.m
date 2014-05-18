//
//  PinManager.m
//
//  Created by Scott Lucien on 2/2/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

#import "PinManager.h"
#import "KeychainItemWrapper.h"

@implementation PinManager

static NSString *const USER_DEFAULTS_PIN = @"USER_DEFAULTS_PIN";
static NSString *const USER_DEFAULTS_DELAY = @"USER_DEFAULTS_DELAY";
static NSString *const USER_DEFAULTS_RESIGN = @"USER_DEFAULTS_RESIGN";
static NSString *const KEYCHAIN_ID = @"PasscodeKeychainIdentifier";

#pragma mark -

+ (BOOL)pinIsEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:USER_DEFAULTS_PIN];
}

+ (void)setPinEnabled:(BOOL)pinEnabled
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:pinEnabled forKey:USER_DEFAULTS_PIN];
    [defaults synchronize];
}

#pragma mark -

+ (NSString *)getPin
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    return [keychain objectForKey:(__bridge id)kSecAttrAccount];
}

+ (void)setPin:(NSString *)newPin
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    [keychain setObject:newPin forKey:(__bridge id)kSecAttrAccount];
}

+ (void)resetPin
{
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    [keychain resetKeychainItem];
}

#pragma mark -

+ (NSDate *)getResignTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return (NSDate *)[defaults objectForKey:USER_DEFAULTS_RESIGN];
}

+ (void)saveResignTime:(NSDate *)resignTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resignTime forKey:USER_DEFAULTS_RESIGN];
    [defaults synchronize];
}

+ (PinDelay)getPinDelay
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:USER_DEFAULTS_DELAY];
}

+ (void)setPinDelay:(PinDelay)delay
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:delay forKey:USER_DEFAULTS_DELAY];
    [defaults synchronize];
}

+ (NSString *)stringForPinDelaySetting:(PinDelay)delay
{
    switch (delay) {
        case PinDelayNone:
            return NSLocalizedString(@"Immediately", nil);
            break;
            
        case PinDelayOneMinute:
            return NSLocalizedString(@"After 1 Minute", nil);
            break;
            
        case PinDelayFiveMinutes:
            return NSLocalizedString(@"After 5 Minutes", nil);
            break;
            
        case PinDelayFifteenMinutes:
            return NSLocalizedString(@"After 15 Minutes", nil);
            break;
            
        case PinDelayOneHour:
            return NSLocalizedString(@"After 1 Hour", nil);
            break;
            
        default:
            break;
    }
}

+ (NSInteger)timeIntervalForDelaySetting:(PinDelay)delay
{
    switch (delay) {
        case PinDelayNone:
            return 0;
            break;
            
        case PinDelayOneMinute:
            return 60;
            break;
            
        case PinDelayFiveMinutes:
            return 300;
            break;
            
        case PinDelayFifteenMinutes:
            return 900;
            break;
            
        case PinDelayOneHour:
            return 3600;
            break;
            
        default:
            break;
    }
}


@end
