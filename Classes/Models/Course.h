//
//  Course.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"
#import "CourseProgress.h"

@class Order;

@interface Course : NSObject {
    int id;
    int offset;
    NSDate *requestedOn;
    NSDate *servedOn;
    NSMutableArray *lines;
    Course *course;
    EntityState entityState;
}

+ (Course *) courseFromJsonDictionary: (NSDictionary *)jsonDictionary order: (Order *)order;
- (NSMutableDictionary *)toDictionary;
- (NSString *) stringForCourse;

NSInteger intSort(id num1, id num2, void *context);
- (bool) hasQueuedItems;

@property int id;
@property int offset;
@property (retain) NSDate *requestedOn;
@property (retain) NSDate *servedOn;
@property (retain) NSMutableArray *lines;
@property (retain) Order *order;
@property (retain) Course *nextCourse;
@property CourseState state;
@property EntityState entityState;

@end
