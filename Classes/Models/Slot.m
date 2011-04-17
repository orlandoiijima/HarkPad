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
#import "SlotTable.h"

@implementation Slot

@synthesize id, startedOn, completedOn, slotTables;

+ (Slot *) slotFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Slot *slot = [[[Slot alloc] init] autorelease];
    slot.id = [[jsonDictionary objectForKey:@"id"] intValue];
    NSNumber *seconds = [jsonDictionary objectForKey:@"startedOn"];
    if((NSNull*)seconds != [NSNull null])
        slot.startedOn = [NSDate dateWithTimeIntervalSince1970:[seconds intValue]];
    
    slot.slotTables = [[NSMutableArray alloc] init];
    id slotTables = [jsonDictionary objectForKey:@"slotTables"];
    for(NSDictionary *item in slotTables)
    {
        id slotTable = [SlotTable slotTableFromJsonDictionary:item];
        [slot.slotTables addObject:slotTable];
    }
    return slot;
}

@end
