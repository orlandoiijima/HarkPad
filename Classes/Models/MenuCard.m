//
//  Menu.m
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import <GameKit/GameKit.h>
#import "MenuCard.h"
#import "Logger.h"
#import "NSDate-Utilities.h"
#import "MenuItem.h"

@implementation MenuCard

@synthesize favorites = _favorites;
@synthesize categories = _categories;
@synthesize validFrom = _validFrom;


- (id)init {
    if ((self = [super init])) {
        {
            _categories = [[NSMutableArray alloc] init];
            _favorites = [[NSMutableArray alloc] init];
            _vatPercentages = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (MenuCard *) menuFromJson:(NSMutableDictionary *)jsonCategories
{
    MenuCard *menuCard = [[MenuCard alloc] initWithDictionary:jsonCategories];
    
    id validFrom = [jsonCategories valueForKey:@"validFrom"];
    if (validFrom != nil)
        menuCard.validFrom = [NSDate dateFromISO8601: validFrom];
    
    for(NSDictionary *categoryDic in [jsonCategories valueForKey:@"categories"])
    {
        ProductCategory *category = [ProductCategory categoryFromJsonDictionary: categoryDic]; 
        [menuCard.categories addObject:category];
    }

    for(NSString *productKey in [jsonCategories valueForKey:@"favorites"])
    {
        Product *product = [menuCard getProduct:productKey];
        [menuCard.favorites addObject:product];
    }

    menuCard.vatPercentages = [jsonCategories valueForKey:@"vatPercentages"];

    for(ProductCategory *category in menuCard.categories)
    {
        for(Product *product in category.products)
        {
            if ([menuCard vatIndexByPercentage:product.vatPercentage] == -1) {
                product.vatPercentage = [menuCard vatPercentageByIndex:0];
            }
            //  menuitems were only filled with key
            if (product.isMenu) {
                for (MenuItem *menuItem in product.items) {
                    menuItem.product = [menuCard getProduct: menuItem.product.key];
                }
            }
        }
    }

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

- (BOOL) isUniqueKey:(NSString *)productId itemToIgnore:(id) itemToIgnore {
    for(ProductCategory *category in _categories)
    {
        for(Product *product in category.products)
        {
            if (itemToIgnore != product)
                if([product.key compare:productId options:NSCaseInsensitiveSearch] == NSOrderedSame)
                    return NO;
        }
    }
    return YES;
}

- (NSString *)vatNameByPercentage: (NSDecimalNumber *)vatPercentage {
    for (NSDictionary *dictionary in _vatPercentages) {
        if ([[dictionary objectForKey:@"percentage"] isEqual:vatPercentage])
            return [dictionary objectForKey:@"name"];
    }
    return @"";
}

- (int)vatIndexByPercentage: (NSDecimalNumber *)vatPercentage {
    for (int j = 0; j < [_vatPercentages count]; j++) {
        NSDictionary *dictionary = [_vatPercentages objectAtIndex:j];
        if ([[dictionary objectForKey:@"percentage"] isEqual:vatPercentage])
            return j;
    }
    return -1;
}

- (NSDecimalNumber *)vatPercentageByIndex: (int)i {
    NSDictionary *dictionary = [_vatPercentages objectAtIndex:i];
    return [dictionary objectForKey:@"percentage"];
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
    card.vatPercentages = [[NSMutableArray allocWithZone:zone] init];
    card.validFrom = [self.validFrom copy];
    for (ProductCategory *category in self.categories) {
        [card.categories addObject:[category copy]];
    }
    for (Product *favorite in self.favorites) {
        [card.favorites addObject:[card getProduct: favorite.key]];
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

    NSMutableArray *favorites = [[NSMutableArray alloc] init];
    for (Product *favorite in _favorites) {
        [favorites addObject:favorite.key];
    }
    [dictionary setObject:favorites forKey:@"favorites"];

    [dictionary setObject:_vatPercentages forKey:@"vatPercentages"];

    return dictionary;
}

- (BOOL)isFavorite: (id)item {
    NSString *key = [item key];
    for (Product *favorite in _favorites) {
        if ([favorite.key isEqualToString: key])
            return YES;
    }
    return NO;
}

- (int)addToFavorites:(id)newItem {
    if (newItem == nil) return -1;

    if ([self isFavorite:newItem])
        return -1;
    int i = [_favorites count];
    NSString *newCategoryName = [newItem isKindOfClass:[Product class]] ? ((Product *)newItem).category.name : @"";
    for (id item in [_favorites reverseObjectEnumerator]) {
        NSString *categoryName = [item isKindOfClass:[Product class]] ? ((Product *)item).category.name : @"";
        if ([categoryName isEqualToString:newCategoryName]) {
            [_favorites insertObject:newItem atIndex:i];
            return i;
        }
        i--;
    }
    [_favorites addObject:newItem];
    return [_favorites count] - 1;
}

- (int)removeFromFavorites:(id) item {
    NSString *key = [item key];
    int i = 0;
    for (Product *favorite in _favorites) {
        if ([favorite.key isEqualToString: key]) {
            [_favorites removeObject:favorite];
            return i;
        }
        i++;
    }
    return -1;
}

@end
