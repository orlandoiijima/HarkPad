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
#import "MenuCard.h"

@implementation Menu

@synthesize name, price, items, key;

//+ (NSMutableArray *) menuFromJson:(NSMutableArray *)menusJson
//{
//    NSMutableArray *menus = [[NSMutableArray alloc] init];
//    for(NSDictionary *menuDic in menusJson)
//    {
//        Menu *menu = [Menu menuFromJsonDictionary: menuDic];
//        [menus addObject:menu];
//    }
//    return menus;
//}

+ (Menu *) menuFromJsonDictionary: (NSDictionary *)jsonDictionary withCard: (MenuCard *)menuCard
{
    Menu *menu = [[Menu alloc] init];
    menu.price = [jsonDictionary objectForKey:@"price"];
    menu.key = [jsonDictionary objectForKey:@"key"];
    menu.name = [jsonDictionary objectForKey:@"name"];
    menu.items = [[NSMutableArray alloc] init];
    id items = [jsonDictionary objectForKey:@"items"];
    for(NSDictionary *item in items)
    {
        MenuItem *menuItem = [MenuItem menuItemFromJsonDictionary: item withCard:menuCard];
        [menu.items addObject:menuItem];
    }
    return menu;
}

+ (Menu *)nullMenu {
    Menu *menu = [[Menu alloc] init];
    return menu;
}

- (id)copyWithZone:(NSZone *)zone {
    Menu *menu = [[Menu allocWithZone:zone] init];
    menu.key = [self.key copy];
    menu.items = [[NSMutableArray allocWithZone:zone] init];
    for (MenuItem *item in self.items) {
        [menu.items addObject:[item copy]];
    }
    return menu;
}

@end
