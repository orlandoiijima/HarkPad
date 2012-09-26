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
    for (NSMutableDictionary *dictionary in totals) {
        NSNumber *type = [dictionary objectForKey:@"type"];
        NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[[dictionary objectForKey:@"amount"] decimalValue]];
        [productTotals.totals setObject:amount forKey:type];
    }
    return productTotals;
}
@end
