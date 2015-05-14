//
//  NSDate+Relativate.m
//  Vestium
//
//  Created by Daniel Koehler on 04/08/2014.
//  Copyright (c) 2014 Vestium Limited. All rights reserved.
//

#import "NSDate+Relativate.h"

@implementation NSDate (Relativate)

+ (NSString *) stringForDisplayFromDate:(NSDate *)date
{
    if (!date) {
        return nil;
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear
                                                         |kCFCalendarUnitMonth
                                                         |kCFCalendarUnitWeek
                                                         |kCFCalendarUnitDay
                                                         |kCFCalendarUnitHour
                                                         |kCFCalendarUnitMinute)
                                               fromDate:date
                                                 toDate:currentDate
                                                options:0];
    if (components.year == 0) {
        // same year
        if (components.month == 0) {
            // same month
            if (components.week == 0) {
                // same week
                if (components.day == 0) {
                    // same day
                    if (components.hour == 0) {
                        // same hour
                        if (components.minute < 1) {
                            // in 1 mins
                            return @"now";
                        } else {
                            return [NSString stringWithFormat:@"%dm", components.minute];
                        }
                    } else {
                        // different hour
                        return [NSString stringWithFormat:@"%dh", components.hour];
                    }
                } else {
                    // different day
                    return [NSString stringWithFormat:@"%dd", components.day];
                }
            } else {
                // different week
                return [NSString stringWithFormat:@"%dW", components.week];
            }
        } else {
            // different month
            return [NSString stringWithFormat:@"%dM", components.month];
        }
    } else {
        // different year
        return [NSString stringWithFormat:@"%dY", components.year];
    }
    
    return @"Unknown.";
}

@end
