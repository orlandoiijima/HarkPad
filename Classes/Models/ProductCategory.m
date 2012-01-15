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
    ProductCategory *category = [[ProductCategory alloc] init];
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

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.id != 0)
        [dic setObject: [NSNumber numberWithInt:self.id] forKey:@"id"];
    if ([self.name length] > 0)
        [dic setObject: self.name forKey:@"name"];
    int r = (int) 255 * [[self.color CGColor] red];
    int g = (int) 255 * [[self.color CGColor] green];
    int b = (int) 255 * [[self.color CGColor] blue];
//    [dic setObject: [self.color CGColor] forKey:@"color"];
    return dic;
}


@end
