//
//  ToBeRequested.m
//  HarkPad
//
//  Created by Willem Bison on 06-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "Backlog.h"
#import "Product.h"
#import "Cache.h"

@implementation Backlog

@synthesize product, totals;


+ (Backlog *) backlogFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Backlog *backlog = [[Backlog alloc] init];
    int productId = [[jsonDictionary objectForKey:@"productId"] intValue];
    backlog.product = [[[Cache getInstance] menuCard] getProduct:productId];
    backlog.totals = [[NSMutableDictionary alloc] init];
    id totals = [jsonDictionary objectForKey:@"totals"];
    if([totals isKindOfClass:[NSArray class]])
    {
        NSNumber *count = [NSNumber numberWithInt:[[totals objectAtIndex:0] intValue]];
        [backlog.totals setObject:count forKey: @"0"];
    }
    else
    for(NSString *key in [totals allKeys])
    {
        NSNumber *count = [NSNumber numberWithInt:[[totals objectForKey: key] intValue]];
        [backlog.totals setObject:count forKey: key];
    }
    return backlog;
}
@end
