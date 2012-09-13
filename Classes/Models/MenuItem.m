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
    menuItem.course = [[jsonDictionary objectForKey:@"Course"] intValue];
    NSString * productId = [jsonDictionary objectForKey:@"Key"];
    menuItem.product = [menuCard getProduct:productId];
    return menuItem;
}

@end
