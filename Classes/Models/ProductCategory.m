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
//    category.id = [[jsonDictionary objectForKey:@"id"] intValue];
    category.sortOrder = [[jsonDictionary objectForKey:@"SortOrder"] intValue];
    category.name = [jsonDictionary objectForKey:@"Name"];
    category.isFood = (BOOL)[[jsonDictionary objectForKey:@"IsFood"] intValue];
//    char *c = (char*)[[jsonDictionary objectForKey:@"Color"] UTF8String];
//    unsigned long color = strtoul(c, nil, strlen(c));
//    float red = ((color >> 24) & 0xFF) / 255.0;
//    float green = ((color >> 16) & 0xFF) / 255.0;
//    float blue = ((color >> 8) & 0xFF) / 255.0;
//    float alpha = (color & 0xFF) / 255.0;
//    category.color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    category.products = [[NSMutableArray alloc] init];
    id products = [jsonDictionary objectForKey:@"Products"];
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
    float r,g,b,a;
    [self.color getRed:&r green:&g blue:&b alpha:&a];
    NSUInteger x = ((long)(255*r) << 24) + ((long)(255*g) << 16) + ((long)(255*b) << 8) + ((long)(255*a));
    [dic setObject: [NSNumber numberWithUnsignedLong:x] forKey:@"color"];
    return dic;
}


@end
