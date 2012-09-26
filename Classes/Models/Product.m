//
//  Product.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"
#import "Product.h"
#import "OrderLineProperty.h"


@implementation Product

@synthesize category, price, name, key, description, sortOrder, properties, isQueued, isDeleted, diet;
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
    Product *product = [[Product alloc] initWithJson:jsonDictionary];
    product.key = [jsonDictionary objectForKey:@"key"];
    product.name = [jsonDictionary objectForKey:@"name"];
    if(product.name == nil)
        product.name = [NSString stringWithString:product.key];
    product.description = [jsonDictionary objectForKey:@"description"];
    product.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    product.isQueued = (BOOL)[[jsonDictionary objectForKey:@"isQueued"] intValue];
    product.isDeleted = (BOOL)[[jsonDictionary objectForKey:@"isDeleted"] intValue];
    product.vat = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"vat"] decimalValue]];
    product.price = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"price"] decimalValue]];
    id val = [jsonDictionary objectForKey:@"diet"];
    if (val != nil)
        product.diet = [val intValue];

    id props =  [jsonDictionary objectForKey:@"properties"];
    if (props != nil) {
        for(NSDictionary *item in props)
        {
            OrderLineProperty *p = [OrderLineProperty propertyFromJsonDictionary:item];
            [product.properties addObject:p];
        }
    }
    return product;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject: self.name forKey:@"name"];
    if (self.description != nil)
        [dic setObject: self.description forKey:@"description"];
    [dic setObject: self.key forKey:@"key"];
    [dic setObject: [NSNumber numberWithBool: self.isDeleted] forKey:@"isDeleted"];
    [dic setObject: self.price forKey:@"price"];
    [dic setObject: self.vat forKey:@"vat"];
    
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

- (void) addProperty: (OrderLineProperty *) orderLineProperty
{
    if ([self hasProperty:orderLineProperty.id])
        return;
    [self.properties addObject:orderLineProperty];
}

- (void) deleteProperty: (OrderLineProperty *) orderLineProperty
{
    for (OrderLineProperty *prop in properties) {
        if(prop.id == orderLineProperty.id) {
            [self.properties removeObject:prop];
            return;
        }
    }
}

+ (Product *)nullProduct {
    Product *product = [[Product alloc] init];
    product.key = @"Unknown";
    product.name = @"Unknown";
    product.description = @"Unknown";
    return product;
}

- (id)copyWithZone:(NSZone *)zone {
    Product *product = [[Product allocWithZone:zone] init];
    product.id = self.id;
    product.key = [self.key copy];
    product.name = [self.name copy];
    product.category = self.category;
    product.entityState = self.entityState;
    product.price = self.price;
    product.properties = self.properties;
    return product;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Product class]] == NO)
        return NO;
    Product *other = (Product *)object;
    return  [key compare:other.key options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (NSUInteger)hash {
    return [key hash];
}
@end
