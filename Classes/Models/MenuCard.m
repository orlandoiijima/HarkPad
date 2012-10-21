//
//  Menu.m
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "MenuCard.h"
#import "Logger.h"
#import "NSDate-Utilities.h"
#import "MenuItem.h"

@implementation MenuCard

@synthesize favorites = _favorites;
@synthesize menus = _menus;
@synthesize categories = _categories;
@synthesize validFrom = _validFrom;


- (id)init {
    if ((self = [super init])) {
        {
            _categories = [[NSMutableArray alloc] init];
            _menus = [[NSMutableArray alloc] init];
            _favorites = [[NSMutableArray alloc] init];
            _vatPercentages = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (MenuCard *) menuFromJson:(NSMutableDictionary *)jsonCategories
{
    MenuCard *menuCard = [[MenuCard alloc] initWithJson:jsonCategories];
    
    id validFrom = [jsonCategories valueForKey:@"validFrom"];
    if (validFrom != nil)
        menuCard.validFrom = [NSDate dateFromISO8601: validFrom];
    
    for(NSDictionary *categoryDic in [jsonCategories valueForKey:@"categories"])
    {
        ProductCategory *category = [ProductCategory categoryFromJsonDictionary: categoryDic]; 
        [menuCard.categories addObject:category];
    }

    for(NSDictionary *menuDic in [jsonCategories valueForKey:@"menus"])
    {
        Menu *menu = [Menu menuFromJsonDictionary: menuDic withCard: menuCard];
        [menuCard.menus addObject:menu];
    }

    for(NSString *productKey in [jsonCategories valueForKey:@"favorites"])
    {
        Product *product = [menuCard getProduct:productKey];
        [menuCard.favorites addObject:product];
    }

    menuCard.vatPercentages = [jsonCategories valueForKey:@"vatPercentages"];

    return menuCard;
}

- (Product *) getProduct: (NSString *) productId
{
    for(ProductCategory *category in _categories)
    {
        for(Product *product in category.products)
        {
            if([product.key compare:productId options:NSCaseInsensitiveSearch] == NSOrderedSame)
                return product;
        }    
    }
    [Logger Error:[NSString stringWithFormat:@"product '%@' not found", productId]];
    return [Product nullProduct];
}

- (NSString *)vatNameByPercentage: (NSDecimalNumber *)vat {
    for (NSDictionary *dictionary in _vatPercentages) {
        if ([[dictionary objectForKey:@"percentage"] isEqual:vat])
            return [dictionary objectForKey:@"name"];
    }
    return @"";
}

- (int)vatIndexByPercentage: (NSDecimalNumber *)vat {
    for (int j = 0; j < [_vatPercentages count]; j++) {
        NSDictionary *dictionary = [_vatPercentages objectAtIndex:j];
        if ([[dictionary objectForKey:@"percentage"] isEqual:vat])
            return j;
    }
    return -1;
}

- (NSDecimalNumber *)vatPercentageByIndex: (int)i {
    NSDictionary *dictionary = [_vatPercentages objectAtIndex:i];
    return [dictionary objectForKey:@"percentage"];
}

- (Menu *) getMenu: (NSString *) menuId
{
    for(Menu *menu in _menus)
    {
        if([menu.key compare:menuId options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return menu;
    }

    [Logger Error:[NSString stringWithFormat:@"menu '%@' not found", menuId]];
    return [Menu nullMenu];
}

- (OrderLineProperty *) getProductProperty: (int)propertyId
{
    for(ProductCategory *category in _categories)
    {
        for(Product *product in category.products)
        {
            for(OrderLineProperty * prop in [product properties])
            {
                if(prop.id == propertyId)
                    return prop;
            }
        }    
    }      
    return nil;
}


- (id)copyWithZone:(NSZone *)zone {
    MenuCard *card = [[MenuCard allocWithZone:zone] init];
    card.categories = [[NSMutableArray allocWithZone:zone] init];
    card.favorites = [[NSMutableArray allocWithZone:zone] init];
    card.menus = [[NSMutableArray allocWithZone:zone] init];
    card.vatPercentages = [[NSMutableArray allocWithZone:zone] init];
    card.validFrom = [self.validFrom copy];
    for (ProductCategory *category in self.categories) {
        [card.categories addObject:[category copy]];
    }
    for (Product *favorite in self.favorites) {
        [card.favorites addObject:[card getProduct: favorite.key]];
    }
    for (Menu *menu in self.menus) {
        Menu *newMenu = [menu copy];
        for (MenuItem *item in newMenu.items) {
            item.product = [card getProduct: item.product.key];
        }
        [card.menus addObject: newMenu];
    }
    card.vatPercentages = [NSMutableArray arrayWithArray:self.vatPercentages];
    return card;
}

- (NSMutableDictionary *)toDictionary {
    NSMutableDictionary *dictionary = [super toDictionary];

    [dictionary setObject: [_validFrom stringISO8601] forKey:@"validFrom"];

    NSMutableArray *categories = [[NSMutableArray alloc] init];
    for (ProductCategory *category in _categories) {
        [categories addObject:[category toDictionary]];
    }
    [dictionary setObject:categories forKey:@"categories"];

    NSMutableArray *menus = [[NSMutableArray alloc] init];
    for (Menu *menu in _menus) {
        [menus addObject:[menu toDictionary]];
    }
    [dictionary setObject:menus forKey:@"menus"];

    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    for (Product *favorite in _favorites) {
        [favorites addObject:favorite.key];
    }
    [dictionary setObject:favorites forKey:@"favorites"];

    [dictionary setObject:_vatPercentages forKey:@"vatPercentages"];

    return dictionary;
}

- (BOOL) isInQuickMenu: (id)item {
    NSString *key = [item key];
    for (Product *favorite in _favorites) {
        if ([favorite.key isEqualToString: key])
            return YES;
    }
    return NO;
}

- (void) addToQuickMenu:(id)item {
    if ([self isInQuickMenu:item])
        return;
    [_favorites addObject:item];
}

- (void) removeFromQuickMenu:(id) item {
    NSString *key = [item key];
    for (Product *favorite in _favorites) {
        if ([favorite.key isEqualToString: key]) {
            [_favorites removeObject:favorite];
            return;
        }
    }
}

@end
