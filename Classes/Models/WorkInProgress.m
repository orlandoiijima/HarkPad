//
//  WorkInProgress.m
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "WorkInProgress.h"


@implementation WorkInProgress

@synthesize course, tableId, productCount;
@synthesize orderId = _orderId;


+ (WorkInProgress *) workFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    WorkInProgress *work = [[WorkInProgress alloc] init];
    id course = [jsonDictionary objectForKey:@"Course"];
    work.course = [Course courseFromJsonDictionary:course order:nil];
    work.orderId = [[jsonDictionary objectForKey:@"OrderId"] intValue];
    work.tableId = [jsonDictionary objectForKey:@"TableId"];
    work.productCount = [[NSMutableArray alloc] init];
    id products = [jsonDictionary objectForKey:@"Products"];
    for(NSDictionary *dic in products)
    {
        ProductCount *productCount = [ProductCount countFromJsonDictionary:dic];
        [work.productCount addObject: productCount];
    }

    return work;
}

@end
