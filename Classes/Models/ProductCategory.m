//
//  ProductCategory.m
//  HarkPad
//
//  Created by Willem Bison on 30-09-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "ProductCategory.h"
#import "Product.h"

@implementation ProductCategory

@synthesize name, products, sortOrder, color, isFood, id;

+ (ProductCategory *) categoryFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    ProductCategory *category = [[[ProductCategory alloc] init] autorelease];
    category.id = [[jsonDictionary objectForKey:@"id"] intValue];
    category.sortOrder = [[jsonDictionary objectForKey:@"sortOrder"] intValue];
    category.name = [jsonDictionary objectForKey:@"name"];
    category.isFood = (BOOL)[[jsonDictionary objectForKey:@"isFood"] intValue];
    char *c = (char*)[[jsonDictionary objectForKey:@"color"] UTF8String];
    unsigned long color = strtoul(c, nil, strlen(c));
    float red = ((color >> 24) & 0xFF) / 255.0;
    float green = ((color >> 16) & 0xFF) / 255.0;
    float blue = ((color >> 8) & 0xFF) / 255.0;
    float alpha = (color & 0xFF) / 255.0; 
    category.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
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
@end
