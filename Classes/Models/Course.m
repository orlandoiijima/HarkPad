//
//  Course.m
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Course.h"
#import "OrderLine.h"
#import "Order.h"
#import "CourseProgress.h"

@implementation Course

@synthesize id, offset, requestedOn, servedOn, lines, entityState, order;
@dynamic state, nextCourse;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.lines = [[NSMutableArray alloc] init];
        entityState = New;
	}
    return(self);
}

+ (Course *) courseFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order
{
    Course *course = [[Course alloc] init];
    course.id = [[jsonDictionary objectForKey:@"id"] intValue];
    course.entityState = None;
    course.offset = [[jsonDictionary objectForKey:@"offset"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"requestedOn"];
    if(seconds != nil && (NSNull *) seconds != [NSNull null])
        course.requestedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    seconds = [jsonDictionary objectForKey:@"servedOn"];
    if(seconds != nil && (NSNull *) seconds != [NSNull null])
        course.servedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    course.order = order;
    return course;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: [NSNumber numberWithInt:self.offset] forKey:@"offset"];
    [dic setObject: [NSNumber numberWithInt:[self.requestedOn timeIntervalSince1970]] forKey:@"requestedOn"];
    [dic setObject: [NSNumber numberWithInt:[self.servedOn timeIntervalSince1970]] forKey:@"servedOn"];
    [dic setObject: [NSNumber numberWithInt:entityState] forKey:@"entityState"];

    return dic;
}

- (NSString *) stringForCourse
{
    NSMutableDictionary *products = [[NSMutableDictionary alloc] init];
    for(OrderLine *line in lines)
    {
        if(line.product.category.isFood)
        {
            NSNumber *count = [products valueForKey: line.product.name];
            if(count == nil)
                count = [NSNumber numberWithInt:1];
            else
                count = [NSNumber numberWithInt: [count intValue] + 1];
            [products setValue:count forKey: line.product.key];
  	      }
    }
    NSString *result = @"";
    NSArray* sortedKeys = [products	 keysSortedByValueUsingSelector:@selector(compare:)];
    for(NSString *key in [sortedKeys reverseObjectEnumerator])
    {
        if([result length] > 0)
            result = [NSString stringWithFormat:@"%@, ", result];
        int count = [[products objectForKey:key] intValue];
        if(count > 1)
            result = [NSString stringWithFormat:@"%@%dx ", result, count]; 
        result = [NSString stringWithFormat:@"%@%@", result, key]; 
    }
    return result;
}

- (Course *) nextCourse
{
    for(Course *course in order.courses) {
        if (course.offset == self.offset + 1)
            return course;
    }
    return nil;
}

- (CourseState) state {
    if (requestedOn == nil)
        return CourseStateNothing;
    if(servedOn == nil)
        return [requestedOn timeIntervalSinceNow] < -15 * 60 ? CourseStateRequestedOverdue : CourseStateRequested;
    return CourseStateServed;
}

@end
