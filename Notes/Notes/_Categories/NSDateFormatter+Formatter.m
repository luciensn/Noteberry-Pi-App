//
//  NSDateFormatter+Formatter.m
//
//  Created by Scott Lucien on 12/10/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

#import "NSDateFormatter+Formatter.h"

@implementation NSDateFormatter (Formatter)

- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    [self setDateFormat:format];
    return [self stringFromDate:date];
}

@end
