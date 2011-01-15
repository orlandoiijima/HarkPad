//
//  Utils.m
//  HarkPad2
//
//  Created by Willem Bison on 29-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Utils.h"


@implementation Utils


+ (NSString *) getSeatString: (int) seat
{
    return [NSString stringWithFormat:@"Stoel %d", seat+1]; 
}

+ (NSString *) getSeatChar: (int) seat
{
    return [NSString stringWithFormat:@"%d", seat+1]; 
}

+ (NSString *) getCourseString: (int) course
{
    NSArray *chars = [NSArray arrayWithObjects:@"A", @"B",@"C",@"D",@"E",@"F",nil];
    return [NSString stringWithFormat:@"Gang %@", [chars objectAtIndex: course]]; 
}

+ (NSString *) getCourseChar: (int) course
{
    NSArray *chars = [NSArray arrayWithObjects:@"A", @"B",@"C",@"D",@"E",@"F",nil];
    return [NSString stringWithFormat:@"%@", [chars objectAtIndex: course]]; 
}

+ (NSString *) getElapsedMinutesString: (NSDate *) date
{
    int elapsed = -1 * [date timeIntervalSinceNow];
    NSString *hour = elapsed > 3600 ? [NSString stringWithFormat:@"%d ", elapsed / 3600] : @"";  
    return [NSString stringWithFormat:@"%@%d'", hour, (elapsed / 60) % 60];
}
@end
