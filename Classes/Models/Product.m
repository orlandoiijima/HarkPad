//
//  Product.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//
#import "Product.h"
#import "OrderLineProperty.h"
#import "Utils.h"


@implementation Product {
}


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
    Product *product = [[Product alloc] initWithDictionary:jsonDictionary];
    product.key = [jsonDictionary objectForKey:@"key"];
    product.name = [jsonDictionary objectForKey:@"name"];
    if(product.name == nil)
        product.name = [NSString stringWithString:product.key];
    product.description = [jsonDictionary objectForKey:@"description"];
    product.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    product.isQueued = (BOOL)[[jsonDictionary objectForKey:@"isQueued"] intValue];
    product.isDeleted = (BOOL)[[jsonDictionary objectForKey:@"isDeleted"] intValue];
//    id daySection = [jsonDictionary objectForKey:@"daySection"];
//    if (daySection != nil) {
//        product.daySection =
//    }
    product.vatPercentage = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"vat"] decimalValue]];
    product.price = [NSDecimalNumber decimalNumberWithDecimal:[[jsonDictionary objectForKey:@"price"] decimalValue]];
    id val = [jsonDictionary objectForKey:@"diet"];
    if (val != nil)
        product.diet = (Diet)[val intValue];

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
    NSMutableDictionary *dic = [super toDictionary];
    [dic setObject: self.name forKey:@"name"];
    if (self.description != nil)
        [dic setObject: self.description forKey:@"description"];
    [dic setObject: self.key forKey:@"key"];
    [dic setObject: [NSNumber numberWithBool: self.isDeleted] forKey:@"isDeleted"];
    [dic setObject: self.price forKey:@"price"];
    [dic setObject:self.vatPercentage forKey:@"vat"];
    
    return dic;
}

- (BOOL) hasProperty: (int)propertyId
{
    for (OrderLineProperty *prop in _properties) {
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
    for (OrderLineProperty *prop in _properties) {
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
    product.key = [_key copy];
    product.name = [_name copy];
    product.description = [self.description copy];
    product.category = _category;
    product.entityState = self.entityState;
    product.price = [_price copy];
    product.diet = _diet;
    product.vatPercentage = _vatPercentage;
    product.properties = [[NSMutableArray allocWithZone:zone] init];
    for (NSString *prop in _properties) {
        [product.properties addObject:[prop copy]];
    }
    return product;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Product class]] == NO)
        return NO;
    Product *other = (Product *)object;
    return  [_key compare:other.key options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (void)setName:(NSString *)aName {
    if ([[Utils trim:aName] isEqualToString:_name])
        return;
    entityState = EntityStateModified;
    _name = [Utils trim:aName];
}

- (void)setKey:(NSString *)aKey {
    if ([[Utils trim:aKey] isEqualToString:_key])
        return;
    entityState = EntityStateModified;
    _key = [Utils trim:aKey];
}

- (void)setDescription:(NSString *)aDescription {
    if ([[Utils trim:aDescription] isEqualToString:_description])
        return;
    entityState = EntityStateModified;
    _description = [Utils trim:aDescription];
}

- (void)setPrice:(NSDecimalNumber *)aPrice {
    if ([aPrice isEqualToNumber:_price]) return;
    entityState = EntityStateModified;
    _price = aPrice;
}

- (void)setDiet:(Diet)aDiet {
    if (_diet == aDiet) return;
    entityState = EntityStateModified;
    _diet = aDiet;
}

- (void)setVatPercentage:(NSDecimalNumber *)aVatPercentage {
    if ([_vatPercentage isEqualToNumber:aVatPercentage]) return;
    entityState = EntityStateModified;
    _vatPercentage = aVatPercentage;
}

- (NSUInteger)hash {
    return [_key hash];
}
@end
