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
@synthesize vat;


- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.properties = [[NSMutableArray alloc] init];
        self.price = [NSDecimalNumber zero];
	}
    return(self);
}

+ (Product *) productFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Product *product = [[Product alloc] init];
    product.key = [jsonDictionary objectForKey:@"key"];
    product.name = [jsonDictionary objectForKey:@"name"];
    product.description = [jsonDictionary objectForKey:@"description"];
    product.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    product.isQueued = (BOOL)[[jsonDictionary objectForKey:@"isQueued"] intValue];
    id vat = [jsonDictionary objectForKey:@"vat"];
    if (vat != nil)
    {
        product.vat = (Vat) [vat intValue];
    }
    product.id = [[jsonDictionary objectForKey:@"id"] intValue];
//    product.properties = [[NSMutableArray alloc] init];
    product.price = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"price"] decimalValue]];
    id props =  [jsonDictionary objectForKey:@"properties"];
    for(NSDictionary *item in props)
    {
        OrderLineProperty *p = [OrderLineProperty propertyFromJsonDictionary:item];
        [product.properties addObject:p];
    }
    return product;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    [dic setObject: self.name forKey:@"name"];
    [dic setObject: self.key forKey:@"key"];
//    [dic setObject: self.description forKey:@"description"];
    [dic setObject: [NSNumber numberWithInt:self.category.id] forKey:@"categoryId"];
    [dic setObject: self.price forKey:@"price"];
    [dic setObject: [NSNumber numberWithInt: self.vat] forKey:@"vat"];
    
    return dic;
}

- (BOOL) hasProperty: (int)propertyId
{
    for (OrderLineProperty *prop in properties) {
        if(prop.id == propertyId)
            return YES;
    }
    return NO;
}

@end
