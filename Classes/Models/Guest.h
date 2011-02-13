//
//  Guest.h
//  HarkPad
//
//  Created by Willem Bison on 28-01-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntityState.h"


@interface Guest : NSObject {
    int id;
    int seat;
    BOOL isMale;
    EntityState entityState;
    NSMutableArray *lines;
}

+ (Guest *) guestFromJsonDictionary: (NSDictionary *)jsonDictionary;
- (NSMutableDictionary *) initDictionary;

@property int id;
@property int seat;
@property BOOL isMale;
@property (retain) NSMutableArray *lines;
@property EntityState entityState;

@end
