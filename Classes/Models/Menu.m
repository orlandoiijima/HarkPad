//
//  Menu.m
//  HarkPad2
//
//  Created by Willem Bison on 02-12-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "Menu.h"
#import "MenuItem.h"
#import "Cache.h"

@implementation Menu

@synthesize id, name, price, items, key;

+ (NSMutableArray *) menuFromJson:(NSMutableArray *)menusJson
{
    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for(NSDictionary *menuDic in menusJson)
    {
        Menu *menu = [Menu menuFromJsonDictionary: menuDic]; 
        [menus addObject:menu];
    }
    return menus;
}

+ (Menu *) menuFromJsonDictionary: (NSDictionary *)jsonDictionary
{
    Menu *menu = [[Menu alloc] init];
    menu.id = [[jsonDictionary objectForKey:@"id"] intValue];
    menu.price = [jsonDictionary objectForKey:@"price"];
    menu.key = [jsonDictionary objectForKey:@"key"];
    menu.name = [jsonDictionary objectForKey:@"name"];
    menu.items = [[NSMutableArray alloc] init];
    id items = [jsonDictionary objectForKey:@"items"];
    for(NSDictionary *item in items)
    {
        MenuItem *menuItem = [MenuItem menuItemFromJsonDictionary: item]; 
        [menu.items addObject:menuItem];
    }
    return menu;
}

@end
