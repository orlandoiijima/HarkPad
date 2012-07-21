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

@synthesize id, course, product;

+ (MenuItem *) menuItemFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    MenuItem *menuItem = [[MenuItem alloc] init];
    menuItem.id = [[jsonDictionary objectForKey:@"Id"] intValue];
    menuItem.course = [[jsonDictionary objectForKey:@"Course"] intValue];
    NSString * productId = [jsonDictionary objectForKey:@"ProductId"];
    menuItem.product = [[[Cache getInstance] menuCard] getProduct:productId];
    return menuItem;
}

@end
