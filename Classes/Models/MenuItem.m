//
//  MenuItem.m
//  HarkPad2
//
//  Created by Willem Bison on 02-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "MenuItem.h"
#import "Cache.h"

@implementation MenuItem

@synthesize course, product;

+ (MenuItem *) menuItemFromJsonDictionary: (NSDictionary *)jsonDictionary withCard: (MenuCard *)menuCard
{
    MenuItem *menuItem = [[MenuItem alloc] init];
    menuItem.course = [[jsonDictionary objectForKey:@"course"] intValue];
    NSString * productId = [jsonDictionary objectForKey:@"key"];
    if (menuCard == nil) {
        //  create dummy to be filled later
        Product *product = [[Product alloc] init];
        product.key = productId;
    }
    else {
        menuItem.product = [menuCard getProduct:productId];
    }
    return menuItem;
}


- (id)copyWithZone:(NSZone *)zone {
    MenuItem *menuItem = [[MenuItem allocWithZone:zone] init];
    menuItem.course = self.course;
    menuItem.product = [self.product copy];
    return menuItem;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:[NSNumber numberWithInt: self.course] forKey:@"course"];
    [dictionary setObject: self.product.key forKey:@"key"];
    return dictionary;
}

@end
