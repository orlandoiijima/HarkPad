//
//  Course.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"

@interface Course : NSObject {
    int id;
    int offset;
    NSDate *requestedOn;
    NSMutableArray *lines;
    EntityState entityState;
}

+ (Course *) courseFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *) initDictionary;

@property int id;
@property int offset;
@property (retain) NSDate *requestedOn;
@property (retain) NSMutableArray *lines;
@property EntityState entityState;

@end
