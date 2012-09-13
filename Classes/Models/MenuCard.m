//
//  Menu.m
//  HarkPad
//
//  Created by Willem Bison on 02-10-10.
//  Copyright (c) 2010 The Attic. All rights reserved.
//

#import "MenuCard.h"
#import "Logger.h"

@implementation MenuCard

@synthesize categories, menus;

- (id)init {
    if ((self = [super init])) {
        {
            categories = [[NSMutableArray alloc] init];
            menus = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

+ (MenuCard *) menuFromJson:(NSMutableDictionary *)jsonCategories
{
    MenuCard *menuCard = [[MenuCard alloc] init];
    for(NSDictionary *categoryDic in [jsonCategories valueForKey:@"Categories"])
    {
        ProductCategory *category = [ProductCategory categoryFromJsonDictionary: categoryDic]; 
        [menuCard.categories addObject:category];
    }
    for(NSDictionary *menuDic in [jsonCategories valueForKey:@"Menus"])
    {
        Menu *menu = [Menu menuFromJsonDictionary: menuDic withCard: menuCard];
        [menuCard.menus addObject:menu];
    }
    return menuCard;
}

- (Product *) getProduct: (NSString *) productId
{
    for(ProductCategory *category in categories)
    {
        for(Product *product in category.products)
        {
            if([product.key compare:productId options:NSCaseInsensitiveSearch] == NSOrderedSame)
                return product;
        }    
    }
    [Logger Error:@"product '%@' not found", productId];
    return [Product nullProduct];
}

- (Menu *) getMenu: (NSString *) menuId
{
    for(Menu *menu in menus)
    {
        if([menu.key compare:menuId options:NSCaseInsensitiveSearch] == NSOrderedSame)
            return menu;
    }   

    [Logger Error:@"menu '%@' not found", menuId];
    return [Menu nullMenu];
}

- (OrderLineProperty *) getProductProperty: (int)propertyId
{
    for(ProductCategory *category in categories)
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
@end
