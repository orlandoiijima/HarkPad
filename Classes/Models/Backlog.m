//
//  ToBeRequested.m
//  HarkPad
//
//  Created by Willem Bison on 06-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Backlog.h"
#import "Cache.h"

@implementation Backlog

@synthesize product, totals;

+ (Backlog *) backlogFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Backlog *backlog = [[Backlog alloc] init];
    NSString *productId = [jsonDictionary objectForKey:@"product"];
    backlog.product = [[[Cache getInstance] menuCard] getProduct:productId];
    backlog.totals = [[NSMutableDictionary alloc] init];
    id totals = [jsonDictionary objectForKey:@"totals"];
    for(NSDictionary *totalsDic in totals)
    {
        NSNumber *distance = [totalsDic objectForKey:@"distance"];
        NSNumber *count = [totalsDic objectForKey:@"count"];
        [backlog.totals setObject:count forKey: distance];
    }
    return backlog;
}
@end
