//
//  KitchenStatistics.m
//  HarkPad
//
//  Created by Willem Bison on 26-02-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "KitchenStatistics.h"


@implementation KitchenStatistics

@synthesize done, inSlot, inProgress, notYetRequested;

+ (KitchenStatistics *) statsFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    KitchenStatistics *stats = [[[KitchenStatistics alloc] init] autorelease];
    stats.done = [[jsonDictionary objectForKey:@"done"] intValue];
    stats.inProgress = [[jsonDictionary objectForKey:@"inProgress"] intValue];
    stats.inSlot = [[jsonDictionary objectForKey:@"inSlot"] intValue];
    stats.notYetRequested = [[jsonDictionary objectForKey:@"notYetRequested"] intValue];    
    return stats;
}

@end
