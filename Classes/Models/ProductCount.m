//
//  ProductCount.m
//  HarkPad
//
//  Created by Willem Bison on 20-04-11.
//  Copyright 2011 The Attic. All rights reserved.
//

#import "ProductCount.h"


@implementation ProductCount

@synthesize count, product;

+ (ProductCount *) countFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    ProductCount *productCount = [[ProductCount alloc] init];
    NSString * productId = [jsonDictionary objectForKey:@"productId"];
    productCount.product = [[[Cache getInstance] menuCard] getProduct:productId];
    productCount.count = [[jsonDictionary objectForKey:@"count"] intValue];
    return productCount;
}

@end
