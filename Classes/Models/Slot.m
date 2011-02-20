//
//  Slot.m
//  HarkPad
//
//  Created by Willem Bison on 20-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Slot.h"
#import "OrderLine.h"
#import "Cache.h"

@implementation Slot

@synthesize id, startedOn, completedOn, lines;

+ (Slot *) slotFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Slot *slot = [[[Slot alloc] init] autorelease];
    slot.id = [[jsonDictionary objectForKey:@"id"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"startedOn"];
    if((NSNull*)seconds != [NSNull null])
        slot.startedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    id lines =  [jsonDictionary objectForKey:@"lines"];
    for(NSDictionary *item in lines)
    {
        [OrderLine orderLineFromJsonDictionary:item guests: nil courses: nil];
    }
    return slot;
}

@end
