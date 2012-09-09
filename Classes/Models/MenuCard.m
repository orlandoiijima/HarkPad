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
        }
    }
    return self;
}

+ (MenuCard *) menuFromJson:(NSMutableDictionary *)jsonCategories
{
    MenuCard *menu = [[MenuCard alloc] init];
    for(NSDictionary *categoryDic in [jsonCategories valueForKey:@"Categories"])
    {
        ProductCategory *category = [ProductCategory categoryFromJsonDictionary: categoryDic]; 
        [menu.categories addObject:category];
    }
    return menu;
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

- (Menu *) getMenu: (int) menuId
{
    for(Menu *menu in menus)
    {
        if(menu.id == menuId)
            return menu;
    }   
    NSLog(@"menu %d not found", menuId);
    return nil;
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
