//
//  PinManager.h
//
//  Created by Scott Lucien on 2/2/14.
//  Copyright (c) 2014 Scott Lucien. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, PinDelay) {
    PinDelayNone,
    PinDelayOneMinute,
    PinDelayFiveMinutes,
    PinDelayFifteenMinutes,
    PinDelayOneHour
};

@interface PinManager : NSObject

+ (BOOL)pinIsEnabled;
+ (void)setPinEnabled:(BOOL)pinEnabled;

+ (NSString *)getPin;
+ (void)setPin:(NSString *)newPin;
+ (void)resetPin;

+ (NSDate *)getResignTime;
+ (void)saveResignTime:(NSDate *)resignTime;
+ (PinDelay)getPinDelay;
+ (void)setPinDelay:(PinDelay)delay;
+ (NSString *)stringForPinDelaySetting:(PinDelay)delay;
+ (NSInteger)timeIntervalForDelaySetting:(PinDelay)delay;

@end
