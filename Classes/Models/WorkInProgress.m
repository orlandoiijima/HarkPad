//
//  WorkInProgress.m
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "WorkInProgress.h"


@implementation WorkInProgress

@synthesize course, table, productCount;

+ (WorkInProgress *) workFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    WorkInProgress *work = [[[WorkInProgress alloc] init] autorelease];
    id course = [jsonDictionary objectForKey:@"course"];
    work.course = [Course courseFromJsonDictionary:course];
    int tableId = [[jsonDictionary objectForKey:@"tableId"] intValue];
    work.table = [[[Cache getInstance] map] getTable: tableId];
    work.productCount = [[NSMutableArray alloc] init];
    id products = [jsonDictionary objectForKey:@"products"];
    for(NSDictionary *dic in products)
    {
        ProductCount *productCount = [ProductCount countFromJsonDictionary:dic];
        [work.productCount addObject: productCount];
    }

    return work;
}

@end
