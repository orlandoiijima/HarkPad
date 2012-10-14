//
//  ProductCategory.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "ProductCategory.h"
#import "Product.h"
#import "UIColor-Expanded.h"

@implementation ProductCategory

@synthesize name, sortOrder, color, isFood;

- (id)init
{
    if ((self = [super init]) != NULL)
	{
        self.products = [[NSMutableArray alloc] init];
        self.color = [UIColor blueColor];
        self.name = @"";
	}
    return(self);
}

+ (ProductCategory *) categoryFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    ProductCategory *category = [[ProductCategory alloc] init];
    category.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    category.name = [jsonDictionary objectForKey:@"name"];
    category.isFood = (BOOL)[[jsonDictionary objectForKey:@"isFood"] intValue];
    NSString *color = [jsonDictionary objectForKey:@"color"];
    category.color = [UIColor colorWithHexString: color];
    category.products = [[NSMutableArray alloc] init];
    id products = [jsonDictionary objectForKey:@"products"];
    for(NSDictionary *item in products)
    {
        Product *product = [Product productFromJsonDictionary: item]; 
        [category.products addObject:product];
        product.category = category;
    }
    return category;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    if ([self.name length] > 0)
        [dic setObject: self.name forKey:@"name"];
    [dic setObject: self.color.hexStringFromColor forKey:@"color"];

    NSMutableArray *products = [[NSMutableArray alloc] init];
    for (Product *product in _products) {
        [products addObject:[product toDictionary]];
    }
    [dic setObject: products forKey:@"products"];
    return dic;
}

- (id)copyWithZone:(NSZone *)zone {
    ProductCategory *category = [[ProductCategory allocWithZone:zone] init];
    category.name = [self.name copy];
    category.color = [self.color copy];
    category.products = [[NSMutableArray allocWithZone:zone] init];
    category.sortOrder = self.sortOrder;
    category.isFood = self.isFood;
    for (Product *product in self.products) {
        Product *newProduct = [product copy];
        [category.products addObject:newProduct];
        newProduct.category = category;
    }
    return category;
}

@end
