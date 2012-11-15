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
#import "NSDate-Utilities.h"

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
    category.type = CategoryTypeStandard;
    category.orderableFromHour = [category hourByTimeSpanString:[jsonDictionary objectForKey:@"orderableFrom"]];
    category.orderableToHour = [category hourByTimeSpanString:[jsonDictionary objectForKey:@"orderableTo"]];
    id products = [jsonDictionary objectForKey:@"products"];
    for(NSDictionary *item in products)
    {
        Product *product = [Product productFromJsonDictionary: item]; 
        [category.products addObject:product];
        product.category = category;
    }
    return category;
}

+ (ProductCategory *) categoryFavorites {
    ProductCategory *favorites = [[ProductCategory alloc] init];
    favorites.name = NSLocalizedString(@"Favorites", nil);
    favorites.type = CategoryTypeFavorites;
    favorites.color = [UIColor greenColor];
    return favorites;
}

+ (ProductCategory *) categoryMenus {
    ProductCategory *favorites = [[ProductCategory alloc] init];
    favorites.name = NSLocalizedString(@"Menus", nil);
    favorites.type = CategoryTypeMenus;
    favorites.color = [UIColor orangeColor];
    return favorites;
}

- (NSMutableDictionary *)toDictionary
{
    NSMutableDictionary *dic = [super toDictionary];
    if ([self.name length] > 0)
        [dic setObject: self.name forKey:@"name"];
    [dic setObject: self.color.hexStringFromColor forKey:@"color"];
    [dic setObject:[NSNumber numberWithInt: self.isFood ? 1:0 ] forKey:@"isFood"];
    [dic setObject:[self toTimeSpanString:self.orderableFromHour] forKey:@"orderableFrom"];
    [dic setObject:[self toTimeSpanString:self.orderableToHour] forKey:@"orderableTo"];
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

- (BOOL) isNowOrderable {
    float now = [[NSDate date] hour] + [[NSDate date] minute] / 60.0;
    if (now > _orderableFromHour && now <= _orderableToHour)
        return YES;
    return NO;
}

- (BOOL) isOrderableAllDay {
    if (_orderableFromHour == 0 && _orderableToHour == 0)
        return YES;
    return NO;
}

- (float) hourByTimeSpanString:(NSString *) timeSpan {
    if ([timeSpan length] == 0)
        return 0.0;
    NSArray *parts = [timeSpan componentsSeparatedByString:@":"];
    if ([parts count] < 2)
        return 0.0;
    float hour = [parts[0] intValue] + [parts[1] intValue]/60.0;
    return hour;
}

- (NSString *) toTimeSpanString: (float)hour {
    int h = (int)(hour * 2);
    return [NSString stringWithFormat:@"%d:%02d", h, h & 1 ? 30 : 0];
}

@end
