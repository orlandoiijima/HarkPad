//
//  Course.m
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Course.h"


@implementation Course

@synthesize id, offset, requestedOn, lines;

+ (Course *) courseFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Course *course = [[[Course alloc] init] autorelease];
    course.id = [[jsonDictionary objectForKey:@"id"] intValue];
    course.offset = [[jsonDictionary objectForKey:@"offset"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"requestedOn"];
    if( (NSNull *) seconds != [NSNull null])
        course.requestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    return course;
}
@end
