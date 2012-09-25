//
//  ProductTotals.m
//  HarkPad
//
//  Created by Willem Bison on 09-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductTotals.h"
#import "Cache.h"

@implementation ProductTotals


@synthesize product, totals;

+ (ProductTotals *) totalsFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    ProductTotals *productTotals = [[ProductTotals alloc] init];
    NSString * productId = [jsonDictionary objectForKey:@"productId"];
    productTotals.product = [[[Cache getInstance] menuCard] getProduct:productId];
    productTotals.totals = [[NSMutableDictionary alloc] init];
    id totals = [jsonDictionary objectForKey:@"totals"];
    int i = 0;
    for(NSNumber *total in totals)
    {
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[total decimalValue]];
        [productTotals.totals setObject:amount forKey: [NSString stringWithFormat:@"%d", i]];
        i++;
    }
    return productTotals;
}
@end
