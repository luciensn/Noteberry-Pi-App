//
//  NSDateFormatter+Formatter.h
//
//  Created by Scott Lucien on 12/10/13.
//  Copyright (c) 2013 Scott Lucien. All rights reserved.
//

@import Foundation;

@interface NSDateFormatter (Formatter)

- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format;

@end
