//
//  Product.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//
#import "CJSONDeserializer.h"
#import "Product.h"
#import "OrderLineProperty.h"


@implementation Product

@synthesize category, price, name, key, description, sortOrder, properties, isQueued, id;

+ (Product *) productFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Product *product = [[[Product alloc] init] autorelease];
    product.key = [jsonDictionary objectForKey:@"key"];
    product.name = [jsonDictionary objectForKey:@"name"];
    product.description = [jsonDictionary objectForKey:@"description"];
    product.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    product.isQueued = (BOOL)[[jsonDictionary objectForKey:@"isQueued"] intValue];    
    product.id = [[jsonDictionary objectForKey:@"id"] intValue];
    product.properties = [[NSMutableArray alloc] init];
    product.price = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"price"] decimalValue]];
    id props =  [jsonDictionary objectForKey:@"properties"];
    for(NSDictionary *item in props)
    {
        OrderLineProperty *p = [OrderLineProperty propertyFromJsonDictionary:item];
        [product.properties addObject:p];
    }
    return product;
}

@end
